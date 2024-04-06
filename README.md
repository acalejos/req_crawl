# ReqCrawl

[![ReqCrawl version](https://img.shields.io/hexpm/v/req_crawl.svg)](https://hex.pm/packages/req_crawl)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/req_crawl/)
[![Hex Downloads](https://img.shields.io/hexpm/dt/req_crawl)](https://hex.pm/packages/req_crawl)
[![Twitter Follow](https://img.shields.io/twitter/follow/ac_alejos?style=social)](https://twitter.com/ac_alejos)

Req plugins to support common crawling functions

## Installation

```elixir
def deps do
  [
    {:req_crawl, "~> 0.2.0"}
    {:saxy, "~> 1.5"} # Optionally to use `ReqCrawl.Sitemap`
  ]
end
```

## Plugins

### ReqCrawl.Robots

A Req plugin to parse robots.txt files

You can attach this plugin to any `%Req.Request` you use for a crawler and it will only run against
URLs with a path of `/robots.txt`.

It outputs a map with the following fields:
  
* `:errors` - A list of any errors encountered during parsing
* `:sitemaps` - A list of the sitemaps
* `:rules` - A map of the rules with User-Agents as the keys and a map with the following values as the fields:
  * `:allow` - A list of allowed paths
  * `:disallow` - A list of the disallowed paths

### ReqCrawl.Sitemap

Gathers all URLs from a Sitemap or SitemapIndex according to the specification described
at <https://sitemaps.org/protocol.html>

Supports the following formats:

* `.xml` (for `sitemap` and `sitemapindex`)
* `.txt` (for `sitemap`)

Outputs a 2-Tuple of `{type, urls}` where `type` is one of `:sitemap` or `:sitemapindex` and `urls` is a list
of URL strings extracted from the body.

Output is stored in the `ReqResponse` in the private field under the `:crawl_sitemap` key
