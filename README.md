# Sitemap

[![CircleCI](https://circleci.com/gh/Schultzer/sitemap.svg?style=svg)](https://circleci.com/gh/Schultzer/sitemap)

Inspired by [sitemap](https://github.com/ikeikeikeike/sitemap) but build for speed and efficiency in mind.

## Example

```elixir
defmodule Myapp.Sitemap do
  use Sitemap

  def publish do
    create host: "https://example.com", files_path: Path.join([:code.priv_dir(:myapp), "static", "sitemaps"]), public_path: "sitemaps" do
      for city <- Myapp.Repo.all(Myapp.City) do
        add Myapp.Routes.my_path(Myapp.Endpoint, :show, city), lastmod: city.update_at
      end
      ping()
    end
  end
end
```

## Benchmarks
When benchmarked against [sitemap](https://github.com/ikeikeikeike/sitemap), `:fast_sitemap` is usually between 5x to 200x faster.

```
Operating System: macOS"
CPU Information: Intel(R) Core(TM) i7-4578U CPU @ 3.00GHz
Number of Available Cores: 4
Available memory: 16 GB
Elixir 1.7.3
Erlang 21.1.1

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 10 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 56 s


Benchmarking fast_sitemap - simple...
Benchmarking sitemap - simple...
Benchmarking fast_sitemap - complex...
Benchmarking sitemap - complex...

Name                             ips        average  deviation         median         99th %
fast_sitemap - simple           1.57         0.64 s     ±5.39%         0.63 s         0.69 s
sitemap - simple                0.31         3.26 s     ±2.64%         3.23 s         3.38 s
fast_sitemap - complex         0.112         8.93 s     ±5.11%         8.93 s         9.25 s
sitemap - complex            0.00735       136.06 s     ±0.00%       136.06 s       136.06 s

Comparison:
fast_sitemap - simple           1.57
sitemap - simple                0.31 - 5.13x slower
fast_sitemap - complex         0.112 - 14.05x slower
sitemap - complex            0.00735 - 214.18x slower

Memory usage statistics:

Name                      Memory usage
fast_sitemap - simple          9.16 MB
sitemap - simple              78.29 MB - 8.55x memory usage
fast_sitemap - complex        20.38 MB - 2.22x memory usage
sitemap - complex           1563.05 MB - 170.60x memory usage

**All measurements for memory usage were the same**
```

## Documentation

[hex documentation for sitemap](https://hexdocs.pm/fast_sitemap/)


## Installation
Add `fast_sitemap` as a dependency to your `mix` project:

```elixir
    defp deps do
      [
        {:fast_sitemap, "~> 0.1.0"}
      ]
    end
```

## LICENSE

(The MIT License)

Copyright (c) 2018 Benjamin Schultzer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

