# ReqCrawl

[![ReqCraw version](https://img.shields.io/hexpm/v/req_craw.svg)](https://hex.pm/packages/req_crawl)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/req_crawl/)
[![Hex Downloads](https://img.shields.io/hexpm/dt/req_crawl)](https://hex.pm/packages/req_crawl)
[![Twitter Follow](https://img.shields.io/twitter/follow/ac_alejos?style=social)](https://twitter.com/ac_alejos)

Req plugins to support common crawling functions

Right now this only consists of the `ReqCrawl.Robots` plugin to parse `robots.txt` files

## Installation

```elixir
def deps do
  [
    {:req_crawl, "~> 0.1.0"}
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

#### Options

* `:robots_output_target` - Where to store the parsed output. Defaults to
  * `:body` - Overwrites the existing body.
  * `:header` - Stores in the response headers under the `:robots` key
