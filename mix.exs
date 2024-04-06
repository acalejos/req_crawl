defmodule ReqCrawl.MixProject do
  use Mix.Project

  def project do
    [
      app: :req_crawl,
      version: "0.1.0",
      elixir: "~> 1.14",
      name: "ReqCrawl",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Req plugins to support common crawling functions",
      source_url: "https://github.com/acalejos/req_crawl",
      package: package(),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs
      ],
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.4"},
      {:saxy, "~> 1.5", optional: true},
      {:ex_doc, ">= 0.0.0", only: :docs, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Andres Alejos"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/acalejos/req_crawl"}
    ]
  end

  defp docs do
    [
      main: "ReqCrawl.Robots"
    ]
  end
end
