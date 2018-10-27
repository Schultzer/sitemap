defmodule Sitemap.Adapter.Virtual do
  @moduledoc false
  use GenServer

  @doc false
  @spec add(binary(), keyword()) :: :ok
  def add(url, opts \\ [lastmod: DateTime.utc_now()]) do
    GenServer.cast(__MODULE__, {:virtual, url, opts})
  end

  @doc false
  @spec add_to_index(binary(), keyword()) :: :ok
  def add_to_index(url, opts \\ [lastmod: DateTime.utc_now()]) do
    GenServer.cast(__MODULE__, {:virtual, url, opts})
  end

  @doc false
  @spec start_link(map()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc false
  @spec stop() :: :ok
  def stop() do
    case GenServer.whereis(__MODULE__) do
      nil -> :ok

      _   ->
        result = GenServer.call(__MODULE__, :retreive)
        GenServer.stop(__MODULE__)
        result
    end
  end

  def ping(urls) do
    GenServer.stop(__MODULE__, {:shutdown, urls})
  end

 # Callbacks

  @spec init(any()) :: {:ok, {nonempty_improper_list(<<_::64, _::_*8>>, <<_::80, _::_*5328>>), any()}}
  def init(config) do
    {:ok, {[Sitemap.header(), Sitemap.index(:start) | Sitemap.urlset(:start)], config}}
  end

  def handle_cast({:virtual, item, attr}, {sitemap, %{host: host} = config}) do
    item = host |> URI.merge(item) |> URI.to_string() |> Sitemap.generate_entry(attr) |> Sitemap.url()
    {:noreply, {[sitemap | item], config}}
  end

  def handle_call(:retreive, _from, {sitemap, config}) do
    sitemap = [sitemap, Sitemap.urlset(:end) | Sitemap.index(:end)]
    {:reply, sitemap, {sitemap, config}}
  end

  def terminate(_reason, {sitemap, _config}) do
    {:ok, sitemap}
  end
end
