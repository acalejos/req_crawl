defmodule ReqCrawl do
  @moduledoc """
  Req plugins to support common crawling functions

  Currently supports parsing the following:

  * `robots.txt`
  * `sitemap.{xml,txt}`
  """
  alias ReqCrawl.{Robots, Sitemap}

  @doc """
  Attach all plugins

  ## Options

  Refer to each respective plugin's documentation for their available options.
  """
  def attach_all(%Req.Request{} = request, options \\ []) do
    request
    |> Robots.attach(options)
    |> Sitemap.attach(options)
  end
end
