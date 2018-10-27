defmodule Sitemap.Adapter.LocalTest do
  use ExUnit.Case

  @date Date.utc_today()
  @expected """
  <?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <urlset
    xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
    xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
      http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'
    xmlns:geo='http://www.google.com/geo/schemas/sitemap/1.0'
    xmlns:news='http://www.google.com/schemas/sitemap-news/0.9'
    xmlns:image='http://www.google.com/schemas/sitemap-image/1.1'
    xmlns:video='http://www.google.com/schemas/sitemap-video/1.1'
    xmlns:mobile='http://www.google.com/schemas/sitemap-mobile/1.0'
    xmlns:pagemap='http://www.google.com/schemas/sitemap-pagemap/1.0'
    xmlns:xhtml='http://www.w3.org/1999/xhtml'
  >
  <url>
    <loc>http://example.com/1</loc>
    <lastmod>#{@date}</lastmod>
  </url><url>
    <loc>http://example.com/2</loc>
    <lastmod>#{@date}</lastmod>
  </url><url>
    <loc>http://example.com/3</loc>
    <lastmod>#{@date}</lastmod>
  </url><url>
    <loc>http://example.com/4</loc>
    <lastmod>#{@date}</lastmod>
  </url><url>
    <loc>http://example.com/5</loc>
    <lastmod>#{@date}</lastmod>
  </url></urlset>
  """

  defmodule Myapp do
    use Sitemap, adapter: Sitemap.Adapter.Local, compress: false


    def generate do
      create host: "http://example.com", files_path: Path.join(:code.priv_dir(:fast_sitemap), "sitemap") do
        for n <- 1..5, do: add("#{n}", lastmod: Date.utc_today())
      end
    end
  end

  setup do
    File.rm_rf!(Path.join(:code.priv_dir(:fast_sitemap), "sitemap"))
    :ok
  end

  test "Genreate valid sitemap" do
    Myapp.generate()
    assert File.read!(Path.join(:code.priv_dir(:fast_sitemap), "sitemap/sitemap1.xml")) == @expected
  end
end
