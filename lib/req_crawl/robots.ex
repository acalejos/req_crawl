defmodule ReqCrawl.Robots do
  @moduledoc """
  A Req plugin to parse robots.txt files

  You can attach this plugin to any `%Req.Request` you use for a crawler and it will only run against
  URLs with a path of `/robots.txt`.

  It outputs a map with the following fields:
  * `:errors` - A list of any errors encountered during parsing
  * `:sitemaps` - A list of the sitemaps
  * `:rules` - A map of the rules with User-Agents as the keys and a map with the following values as the fields:
    * `:allow` - A list of allowed paths
    * `:disallow` - A list of the disallowed paths

  ## Options

  * `:robots_output_target` - Where to store the parsed output. Defaults to
    * `:body` - Overwrites the existing body.
    * `:header` - Stores in the response headers under the `:robots` key
  """
  def attach(%Req.Request{} = request, options \\ []) do
    request
    |> Req.Request.register_options([:robots_output_target])
    |> Req.Request.merge_options(options)
    |> Req.Request.append_response_steps(parse_robots: &parse_robots_txt/1)
  end

  # Regexes taken from https://github.com/ravern/gollum/blob/61872d14e70e3ed8a6f619eb0ff066b8b1548ddc/lib/gollum/parser.ex#L35
  defp parse_robots_txt({%Req.Request{url: %URI{path: "/robots.txt"}} = request, response}) do
    output_target = Map.get(request.options, :robots_output_target, :body)

    {%{errors: errors, rules: rules, sitemaps: sitemaps}, last_agents, last_body, _prev} =
      response.body
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()
      |> Enum.reduce({%{errors: [], sitemaps: [], rules: []}, [], [], nil}, fn
        {<<"#", _rest::binary>>, _idx}, acc ->
          acc

        {"", _idx}, acc ->
          acc

        {line, idx}, {acc, current_agents, current_body, previous} ->
          cond do
            path = Regex.run(~r/^allow:?\s(.+)$/i, line, capture: :all_but_first) ->
              path = hd(path)

              if String.starts_with?(path, "/") do
                {
                  acc,
                  current_agents,
                  [{:allow, path} | current_body],
                  :allow
                }
              else
                {
                  Map.update!(acc, :errors, fn errors ->
                    [
                      "Line #{idx + 1}: Invalid path in 'Allow' directive. Path must start with '/', got '#{path}'"
                      | errors
                    ]
                  end),
                  current_agents,
                  current_body,
                  :allow
                }
              end

            path = Regex.run(~r/^disallow:?\s(.+)$/i, line, capture: :all_but_first) ->
              path = hd(path)

              if String.starts_with?(path, "/") do
                {
                  acc,
                  current_agents,
                  [{:disallow, path} | current_body],
                  :disallow
                }
              else
                {
                  Map.update!(acc, :errors, fn errors ->
                    [
                      "Line #{idx + 1}: Invalid path in 'Disallow' directive. Path must start with '/', got '#{path}'"
                      | errors
                    ]
                  end),
                  current_agents,
                  current_body,
                  :disallow
                }
              end

            agent = Regex.run(~r/^user-agent:?\s(.+)$/i, line, capture: :all_but_first) ->
              case previous do
                # First group in the file
                nil ->
                  {acc, [hd(agent)], current_body, :user_agent}

                # Stacked user agents -> this group of rules applies to both
                :user_agent ->
                  {acc, [hd(agent) | current_agents], current_body, :user_agent}

                # Start of a new group -- Insert the previous one
                _ ->
                  {
                    Map.update!(acc, :rules, fn rules ->
                      [{current_agents, current_body} | rules]
                    end),
                    [hd(agent)],
                    [],
                    :user_agent
                  }
              end

            sitemap = Regex.run(~r/^sitemap:?\s(.+)$/i, line, capture: :all_but_first) ->
              {
                Map.update!(acc, :sitemaps, fn sitemaps -> [hd(sitemap) | sitemaps] end),
                current_agents,
                current_body,
                :sitemap
              }

            true ->
              {
                Map.update!(acc, :errors, fn errors ->
                  ["Line #{idx + 1}: Bad directive" | errors]
                end),
                current_agents,
                current_body,
                previous
              }
          end
      end)

    rules =
      Enum.reduce([{last_agents, last_body} | rules], %{}, fn {agents, body}, acc ->
        body = body |> Enum.group_by(fn {k, _v} -> k end, fn {_k, v} -> v end)

        Enum.reduce(agents, acc, fn agent, ac ->
          Map.update(ac, agent, body, fn existing_body ->
            Map.merge(existing_body, body, fn _k, v1, v2 ->
              (v1 ++ v2) |> Enum.uniq()
            end)
          end)
        end)
      end)

    robots = %{errors: errors, sitemaps: sitemaps, rules: rules}

    case output_target do
      :body ->
        {request, struct!(response, body: robots)}

      :header ->
        {request,
         struct!(response,
           headers: Map.update(response, :headers, %{}, &Map.put_new(&1, "robots", robots))
         )}
    end
  end

  defp parse_robots_txt(payload), do: payload
end
