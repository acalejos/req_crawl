defmodule ReqCrawl.Sitemap.TxtHandler do
  @moduledoc false
  def parse(body) do
    urls =
      body
      |> String.split("\n")
      |> Enum.reject(&(String.trim(&1) == ""))

    {:sitemap, urls}
  end
end
