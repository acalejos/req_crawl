defmodule ReqCrawl.Sitemap do
  @moduledoc """
  Gathers all URLs from a Sitemap or SitemapIndex according to the specification described
  at https://sitemaps.org/protocol.html

  Supports the following formats:

  * `.xml` (for `sitemap` and `sitemapindex`)
  * `.txt` (for `sitemap`)

  Outputs a 2-Tuple of `{type, urls}` where `type` is one of `:sitemap` or `:sitemapindex` and `urls` is a list
  of URL strings extracted from the body.

  Output is stored in the `ReqResponse` in the private field under the `:crawl_sitemap` key
  """
  alias ReqCrawl.Sitemap.{XMLHandler, TxtHandler}

  def attach(%Req.Request{} = request, _options \\ []) do
    request
    |> Req.Request.append_response_steps(parse_sitemap: &parse_sitemap/1)
  end

  defp parse_sitemap({%Req.Request{url: %URI{path: "/sitemap" <> rest}} = request, response}) do
    ext = rest |> String.split(".") |> Enum.reverse() |> hd()

    result =
      case ext do
        "xml" ->
          XMLHandler.parse(response.body)

        "txt" ->
          TxtHandler.parse(response.body)

        e when e in [".atom", ".rss"] ->
          {:error, "#{inspect(e)}-formatted sitemaps types are not yet supported"}

        _ ->
          {:error, "#{inspect(ext)} is not a valid sitemap file extension"}
      end

    {request, Req.Response.put_private(response, :crawl_sitemap, result)}
  end

  defp parse_sitemap(payload), do: payload
end
