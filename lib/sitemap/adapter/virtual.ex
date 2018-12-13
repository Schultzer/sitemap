defmodule Sitemap.Adapter.Virtual do
  @moduledoc false
  use Sitemap.Adapter

  @sitemap ["""
  <?xml version="1.0" encoding="UTF-8"?>
  <sitemapindex
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
      http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd"
    xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  >
  <urlset
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
      http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
    xmlns:geo="http://www.google.com/geo/schemas/sitemap/1.0"
    xmlns:news="http://www.google.com/schemas/sitemap-news/0.9"
    xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
    xmlns:video="http://www.google.com/schemas/sitemap-video/1.1"
    xmlns:mobile="http://www.google.com/schemas/sitemap-mobile/1.0"
    xmlns:pagemap="http://www.google.com/schemas/sitemap-pagemap/1.0"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
  >
  """,
  [],
  """
  </urlset>
  </sitemapindex>
  """]

  def pre_work(_config) do
    Sitemap.Config.update(%{compress: false, files_path: :virtual, index_path: :virtual, max_sitemap_files: :virtual, max_sitemap_links: :virtual})
    :ets.insert(:sitemap, {:virtual, @sitemap})
  end

  def post_work(_config) do
    state()
  end

  def add(uri, attr, %{host: host}) do
    uri
    |> Sitemap.generate_entry(attr, host)
    |> Sitemap.url()
    |> update(state())
  end

  def add_to_index(uri, attr, config) do
    add(uri, attr, config)
  end

  defp update(url, [first, links, last]) do
    state = [first, [links | url], last]
    :ets.insert(:sitemap, {:virtual, state})
    state
  end

  defp state() do
    case :ets.lookup(:sitemap, :virtual) do
      []               -> @sitemap

      [virtual: state] -> state
    end
  end
end
