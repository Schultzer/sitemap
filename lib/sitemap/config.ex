defmodule Sitemap.Config do
  @moduledoc false

  @type t() :: %{
    adapter: module(),
    bucket: binary(),
    compress: boolean(),
    files_path: term(),
    host: binary() | URI.t(),
    index_path: binary() | URI.t(),
    max_sitemap_files: integer(),
    max_sitemap_links: integer(),
    name: binary(),
    public_path: binary(),
  }

  @defualt %{
    adapter: Sitemap.Adapter.Local,
    bucket: "",
    compress: true,
    files_path: "sitemap",
    host: "http://example.com",
    index_path: "http://example.com/sitemap/sitemap.xml.gz",
    max_sitemap_files: 10000,
    max_sitemap_links: 10000,
    name: "sitemap",
    public_path: "sitemap"
  }

  @doc false
  @spec defualt() :: t()
  def defualt(), do: @defualt

  @doc false
  @spec init(module()) :: true
  def init(module) do
    create()
    update(%{@defualt | name: module |> Module.split() |> Enum.at(-1) |> Macro.underscore()})
  end

  @doc false
  @spec create() :: :sitemap
  defp create() do
    case :ets.info(:sitemap) do
      :undefined -> :ets.new(:sitemap, [:set, :public, :named_table])

      _          -> :sitemap
    end
  end

  @doc false
  @spec get() :: t() | []
  def get() do
    case :ets.lookup(:sitemap, :config) do
      []               -> %{}
      [config: config] -> config
    end
  end

  @doc false
  @spec update(t() | map()) :: true
  def update(config \\ %{}), do: :ets.insert(:sitemap, {:config, Map.merge(get(), Map.new(config))})
end
