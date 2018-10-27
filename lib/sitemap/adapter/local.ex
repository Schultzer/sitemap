defmodule Sitemap.Adapter.Local do
  @moduledoc false
  use GenServer

  @doc false
  @spec add(binary(), keyword()) :: :ok
  def add(url, opts) do
    GenServer.cast(__MODULE__, {:sitemap_file, url, opts})
  end

  @doc false
  @spec add_to_index(binary(), keyword()) :: :ok
  def add_to_index(url, opts) do
    GenServer.cast(__MODULE__, {:index_file, url, opts})
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

      _   -> GenServer.stop(__MODULE__)
    end
  end

  def ping(urls) do
    GenServer.stop(__MODULE__, {:shutdown, urls})
  end

  # Callbacks

  for {key, bool, write_opts, ext} <- [{:compress, true, [:write, :compressed], ".xml.gz"}, {:compress, false, [:write], ".xml"}] do
    def init(%{:files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)} = config) do
      if File.exists?(path), do: File.rm_rf!(path)
      File.mkdir_p(path)
      file_count = 1
      sitemap_path = "#{name}#{file_count}#{unquote(ext)}"
      index_path = "#{name}#{unquote(ext)}"
      sitemap_file = path |> Path.join(sitemap_path) |> File.open!(unquote(write_opts))
      index_file = path |> Path.join(index_path) |> File.open!(unquote(write_opts))

      IO.write(index_file, [Sitemap.header(), Sitemap.index(:start) | Sitemap.sitemap(Path.join([public, sitemap_path]))])
      IO.write(sitemap_file, [Sitemap.header() | Sitemap.urlset(:start)])
      {:ok, {0, 1, file_count, sitemap_file, index_file, config}}
    end

    def handle_cast({:sitemap_file, item, attr}, {max_files, links, file_count, _sitemap_file, index_file, %{:max_sitemap_links => max_links, :max_sitemap_files => max_files, :host => host, :files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)} = config}) when max_links - links == 1 do
      item = host |> URI.merge(item) |> URI.to_string() |> Sitemap.generate_entry(attr) |> Sitemap.url()
      file_count = file_count + 1
      new_index_path = "#{name}#{file_count}#{unquote(ext)}"
      new_index_file = path |> Path.join(new_index_path) |> File.open!(unquote(write_opts))
      IO.write(index_file, [Sitemap.sitemap(Path.join([public, new_index_path])), Sitemap.index(:end)])
      File.close(index_file)
      file_count = file_count + 1
      new_sitemap_path = "#{name}#{file_count}#{unquote(ext)}"
      new_sitemap_file = File.open!(Path.join(path, new_sitemap_path), unquote(write_opts))
      IO.write(new_index_file, [Sitemap.header(), Sitemap.index(:start) | Sitemap.sitemap(Path.join([public, new_sitemap_path]))])
      IO.write(new_sitemap_file, item)
      {:noreply, {0, 1, file_count, new_sitemap_file, new_index_file, config}}
    end

    def handle_cast({:sitemap_file, item, attr}, {entries, links, file_count, sitemap_file, index_file, %{:max_sitemap_links => max_links, :host => host, :files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)} = config}) when max_links - links == 1 do
      item = host |> URI.merge(item) |> URI.to_string() |> Sitemap.generate_entry(attr) |> Sitemap.url()
      file_count = file_count + 1
      new_index_path = "#{name}#{file_count}#{unquote(ext)}"
      new_index_file = path |> Path.join(new_index_path) |> File.open!(unquote(write_opts))

      IO.write(index_file, [Sitemap.sitemap(Path.join([public, new_index_path])), Sitemap.index(:end)])
      File.close(index_file)
      IO.write(new_index_file, [Sitemap.header() | Sitemap.index(:start)])
      IO.write(sitemap_file, item)
      {:noreply, {entries + 1, 0, file_count, sitemap_file, new_index_file, config}}
    end

    def handle_cast({:sitemap_file, item, attr}, {max_files, links, file_count, sitemap_file, index_file, %{:max_sitemap_files => max_files, :host => host, :files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)} = config}) do
      item = host |> URI.merge(item) |> URI.to_string() |> Sitemap.generate_entry(attr) |> Sitemap.url()
      IO.write(sitemap_file, Sitemap.urlset(:end))
      File.close(sitemap_file)
      file_count = file_count + 1
      new_sitemap_file_path = "#{name}#{file_count}#{unquote(ext)}"
      new_sitemap_file = File.open!(Path.join(path, new_sitemap_file_path), unquote(write_opts))
      IO.write(new_sitemap_file, [Sitemap.header(), Sitemap.urlset(:start) | item])
      IO.write(index_file, Sitemap.sitemap(Path.join([public, new_sitemap_file_path])))
      {:noreply, {0, links + 1, file_count, new_sitemap_file, index_file, config}}
    end

    def handle_cast({:index_file, item, attr}, {entries, links, file_count, sitemap_file, index_file, %{:max_sitemap_links => max_links, :host => host, :files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)} = config}) when max_links - links == 1 do
      item = host |> URI.merge(item) |> URI.to_string() |> Sitemap.generate_entry(attr) |> Sitemap.sitemap()
      file_count = file_count + 1
      new_index_path = "#{name}#{file_count}#{unquote(ext)}"
      new_index_file = path |> Path.join(new_index_path) |> File.open!(unquote(write_opts))
      IO.write(index_file, [Sitemap.sitemap(Path.join([public, new_index_path])), Sitemap.index(:end)])
      IO.write(new_index_file, [Sitemap.header(), Sitemap.index(:start) | item])
      {:noreply, {entries, 1, file_count, sitemap_file, index_file, config}}
    end
  end

  def handle_cast({:sitemap_file, item, attr}, {entries, links, file_count, sitemap_file, index_file, %{host: host} = config}) do
    item = host |> URI.merge(item) |> URI.to_string() |> Sitemap.generate_entry(attr) |> Sitemap.url()
    IO.write(sitemap_file, item)
    {:noreply, {entries + 1, links, file_count, sitemap_file, index_file, config}}
  end

  def handle_cast({:index_file, item, attr}, {entries, links, file_count, sitemap_file, index_file, %{host: host} = config}) do
    item = host |> URI.merge(item) |> URI.to_string() |> Sitemap.generate_entry(attr) |> Sitemap.sitemap()
    IO.write(index_file, item)
    {:noreply, {entries, links + 1, file_count, sitemap_file, index_file, config}}
  end

  def terminate({:shutdown, urls}, {_entries, _links, _file_count, sitemap_file, index_file, %{index_path: path}}) do
    IO.write(index_file, Sitemap.index(:end))
    File.close(index_file)
    IO.write(sitemap_file, Sitemap.urlset(:end))
    File.close(sitemap_file)
    for url <- ['http://google.com/ping?sitemap=#{path}', 'http://www.bing.com/webmaster/ping.aspx?sitemap=#{path}' | urls] do
      :httpc.request('#{url}')
      IO.puts("Successful ping of #{url}")
    end
  end
  def terminate(_reason, {_entries, _links, _file_count, sitemap_file, index_file, _config}) do
    IO.write(index_file, Sitemap.index(:end))
    File.close(index_file)
    IO.write(sitemap_file, Sitemap.urlset(:end))
    File.close(sitemap_file)
  end
end
