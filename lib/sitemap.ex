defmodule Sitemap do
  @moduledoc """
  Documentation for Sitemaps.
  """

  alias Sitemap.{Alternate, Config, Geo, Image, News, PageMap, Video}

  @header """
  <?xml version="1.0" encoding="UTF-8"?>
  """
  @index """
  <sitemapindex
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
      http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd"
    xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  >
  </sitemapindex>
  """
  @urlset """
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
  </urlset>
  """

  defdelegate news(images), to: News, as: :new
  defdelegate videos(videos), to: Video, as: :new
  defdelegate images(images), to: Image, as: :new
  defdelegate pagemap(pagemap), to: PageMap, as: :new
  defdelegate geo(geo), to: Geo, as: :new
  defdelegate alternates(geo), to: Alternate, as: :new

  @doc false
  defmacro __using__(config) do
    quote do
      Config.init(__MODULE__)
      Config.update(unquote(config))

      defmacro create(params, [do: block]) do
        quote do
          Config.update(unquote(params))
          pre_work()
          unquote(block)
          post_work()
        end
      end

      def pre_work(config \\ Config.get())
      def pre_work(config) do
        config.adapter.pre_work(config)
      end

      def post_work(config \\ Config.get())
      def post_work(config) do
        config.adapter.post_work(config)
      end

      def add(uri, attr \\ [], config \\ Config.get())
      def add(uri, attr, config) do
        config.adapter.add(uri, attr, config)
      end

      def add_to_index(uri, attr \\ [], config \\ Config.get())
      def add_to_index(uri, attr, config) do
        config.adapter.add_to_index(uri, attr, config)
      end

      def ping(urls \\ [], config \\ Config.get())
      def ping(urls, config) do
        config.adapter.ping(urls, config)
      end
    end
  end

  @doc false
  @spec generate_entry(binary(), keyword(), binary()) :: [binary()]
  def generate_entry(url, attr, host) do
    url = host |> URI.merge(url) |> URI.to_string()
    [lastmod: DateTime.utc_now()]
    |> Keyword.merge(attr)
    |> Enum.reduce(loc(url), fn {key, value}, result -> [result | Kernel.apply(__MODULE__, key, [value])] end)
  end

  @doc false
  @spec header() :: binary()
  def header(), do: @header

  @doc false
  @spec index() :: binary()
  def index(), do: @index

  @doc false
  @spec urlset() :: binary()
  def urlset(), do: @urlset

  @doc false
  @spec url(list()) :: iodata()
  def url([_ | _] = entries) do
    ["<url>", entries, "\n</url>"]
  end

  @doc false
  @spec sitemap(binary(), binary()) :: iodata()
  def sitemap(path, file) do
    path
    |> Path.join(file)
    |> sitemap()
  end

  @doc false
  @spec sitemap(binary() | [binary()]) :: iodata()
  def sitemap([<<"\n  <loc>", _::binary()>> | _] = sitemap)  do
    ["<sitemap>", sitemap, "\n</sitemap>"]
  end
  def sitemap(sitemap) when is_binary(sitemap) do
    ["<sitemap>", loc(sitemap), lastmod(DateTime.utc_now()), "\n</sitemap>"]
  end

  @doc false
  @spec loc(binary() | list()) :: iodata()
  def loc(loc) when is_binary(loc) or is_list(loc) do
    "\n\s\s<loc>#{loc}</loc>"
  end

  @doc false
  @spec lastmod(Date.t() | DateTime.t() | NaiveDateTime.t()) :: iodata()
  def lastmod(%datetime{} = lastmod) when datetime in [Date, DateTime, NaiveDateTime] do
    "\n\s\s<lastmod>#{datetime.to_iso8601(lastmod)}</lastmod>"
  end

  @doc false
  @spec changefreq(:always | :hourly | :daily | :weekly | :monthly | :yearly | :never) :: binary()
  def changefreq(freq)
  for freq <- ~w(always hourly daily weekly monthly yearly never)a ++ ~w(always hourly daily weekly monthly yearly never) do
    def changefreq(unquote(freq)) do
      "\n\s\s<changefreq>#{String.capitalize("#{unquote(freq)}")}</changefreq>"
    end
  end

  @doc false
  @spec priority(float()) :: binary()
  def priority(priority) when is_float(priority) and priority >= 0.0 and priority <= 1.0 do
    "\n\s\s<priority>#{Float.to_string(priority)}</priority>"
  end

  @spec mobile(any()) :: [] | binary()
  def mobile(true), do: "\n\s\s<mobile:mobile/>"
  def mobile(_), do: []
end
