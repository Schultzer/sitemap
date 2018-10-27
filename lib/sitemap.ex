defmodule Sitemap do
  @moduledoc """
  Documentation for FastSitemaps.
  """

  @header "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  @indexstart """
  <sitemapindex
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
      http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd"
    xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  >
  """
  @indexend "</sitemapindex>\n"
  @urlsetstart """
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
  """
  @urlsetend "</urlset>\n"

  defdelegate news(images), to: Sitemap.News, as: :new
  defdelegate videos(videos), to: Sitemap.Video, as: :new
  defdelegate images(images), to: Sitemap.Image, as: :new
  defdelegate pagemap(pagemap), to: Sitemap.PageMap, as: :new
  defdelegate geo(geo), to: Sitemap.Geo, as: :new
  defdelegate alternates(geo), to: Sitemap.Alternate, as: :new


  @doc false
  defmacro __using__(params) do
    quote do
      @params Map.merge(%{name: "sitemap", public_path: "sitemap", files_path: "sitemap", compress: true,
                          host: "http://example.com", index_path: "http://example.com/sitemap/sitemap.xml.gz",
                          max_sitemap_files: 10_000, max_sitemap_links: 10_000, adapter: Sitemap.Adapter.Local}, Map.new(unquote(params)))
      defmacro create(params, [do: block]) do
        quote do
          config = @params
                  |> Map.merge(Map.new(unquote(params)))
                  |> Sitemap.normelize_config()
                  |> Sitemap.validate_config()
                  |> Sitemap.put_index_path()

          config.adapter.start_link(config)
          unquote(block); config.adapter.stop()
        end
      end

      defdelegate add(uri, attr \\ []), to: @params.adapter
      defdelegate add_to_index(uri, attr \\ []), to: @params.adapter
      defdelegate ping(urls \\ []), to: @params.adapter
    end
  end

  @doc false
  @spec generate_entry(binary(), keyword()) :: [binary()]
  def generate_entry(url, attr \\ []) do
    [lastmod: DateTime.utc_now()]
    |> Keyword.merge(attr)
    |> Enum.reduce(loc(url), fn {key, value}, result -> [result | Kernel.apply(__MODULE__, key, [value])] end)
  end

  @doc false
  @spec header() :: binary()
  def header(), do: @header

  @doc false
  @spec index(:start | :end) :: binary()
  def index(:start), do: @indexstart
  def index(:end), do: @indexend

  @doc false
  @spec urlset(:start | :end) :: binary()
  def urlset(:start), do: @urlsetstart
  def urlset(:end), do: @urlsetend

  @doc false
  @spec url(list()) :: iodata()
  def url([_ | _] = entries) do
    ["<url>", entries, "\n</url>"]
  end

  @doc false
  @spec sitemap(binary() | [binary()]) :: iodata()
  def sitemap([["\n  <loc>" | _] | _] = sitemap)  do
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

  @doc false
  @spec normelize_config(map()) :: map()
  def normelize_config(%{host: <<host::binary()>>, public_path: <<public::binary()>>, files_path: <<path::binary()>>, adapter: Sitemap.Adapter.S3} = config) do
    host = URI.parse(host)
    %{config | host: host, public_path: host |> URI.merge(public) |> URI.to_string(), files_path: Path.join(tmp_dir(), path)}
  end
  def normelize_config(%{host: <<host::binary()>>, public_path: <<public::binary()>>} = config) do
    host = URI.parse(host)
    %{config | host: host, public_path: host |> URI.merge(public) |> URI.to_string()}
  end

  @doc false
  @spec tmp_dir() :: binary()
  def tmp_dir() do
    [tmpdir, tmp, temp] = [System.get_env("TMPDIR"), System.get_env("TMP"), System.get_env("TEMP")]
    cond do
      is_binary(tmpdir) -> tmpdir

      is_binary(tmp)    -> tmp

      is_binary(temp)   -> temp

      true              -> Path.join(:code.priv_dir(:fast_sitemap), "tmp")
    end
  end

  @spec validate_config(map()) :: map()
  def validate_config(%{adapter: Sitemap.Adapter.S3, bucket: <<bucket::binary()>>} = config) when byte_size(bucket) > 0 do
    config
  end
  def validate_config(%{adapter: Sitemap.Adapter.S3} = config)do
    raise ArgumentError, "No bucket was configured #{inspect config}"
  end
  def validate_config(config), do: config

  def put_index_path(%{public_path: path, name: name, compress: true} = config) do
    %{config | index_path: Path.join([path, name, ".xml.gz"])}
  end
  def put_index_path(%{public_path: path, name: name, compress: false} = config) do
    %{config | index_path: Path.join([path, name, ".xml"])}
  end
end
