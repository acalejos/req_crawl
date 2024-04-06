defmodule ReqCrawl.Sitemap.XMLHandler do
  @moduledoc false
  @behaviour Saxy.Handler

  def handle_event(:start_document, _prolog, urls), do: {:ok, {nil, [], urls}}

  def handle_event(:end_document, _data, {type, _path, urls}) do
    case type do
      "sitemapindex" ->
        {:ok, {:sitemapindex, urls}}

      "urlset" ->
        {:ok, {:sitemap, urls}}

      _ ->
        {:ok, {:unknown, urls}}
    end
  end

  def handle_event(:start_element, {name, _attributes}, {type, path, urls}) do
    if is_nil(type) do
      {:ok, {name, [name | path], urls}}
    else
      {:ok, {type, [name | path], urls}}
    end
  end

  def handle_event(:end_element, _name, {type, path, urls}) do
    [_head | tail] = path
    {:ok, {type, tail, urls}}
  end

  def handle_event(:characters, chars, {type, path, urls} = state) do
    ret =
      case path do
        ["loc", "sitemap", "sitemapindex"] ->
          {type, path, [chars | urls]}

        ["loc", "url", "urlset"] ->
          {type, path, [chars | urls]}

        _ ->
          state
      end

    {:ok, ret}
  end

  def parse(body) do
    case Saxy.parse_string(body, __MODULE__, []) do
      {:ok, result} ->
        result

      _ ->
        {:error, "Could not parse XML Document"}
    end
  end
end
