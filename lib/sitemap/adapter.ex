defmodule Sitemap.Adapter do
  @moduledoc false

  alias Sitemap.Config

  @callback pre_work(Config.t()) :: term()
  @callback post_work(Config.t()) :: term()
  @callback add(uri :: binary(), attr :: keyword(), Config.t()) :: term()
  @callback add_to_index(uri :: binary(), attr :: keyword(), Config.t()) :: term()
  @callback ping(urls :: [binary()], Config.t()) :: term()
  @callback upload(Config.t()) :: term()
  @callback tmp_dir() :: term()

  defmacro __using__(_config) do
    quote do
      @behaviour unquote(__MODULE__)

      def pre_work(config) do
        unquote(__MODULE__).pre_work(config)
      end

      def post_work(config) do
        unquote(__MODULE__).post_work(config)
      end

      def add(uri, attr \\ [], config) do
        unquote(__MODULE__).add(uri, attr, config)
      end

      def add_to_index(uri, attr \\ [], config) do
        unquote(__MODULE__).add_to_index(uri, attr, config)
      end

      def ping(urls \\ [], config) do
        unquote(__MODULE__).ping(urls, config)
      end

      def upload(config) do
        unquote(__MODULE__).upload(config)
      end

      def tmp_dir() do
        unquote(__MODULE__).tmp_dir()
      end

      defoverridable unquote(__MODULE__)
    end
  end

  def pre_work(%{host: <<host::binary()>>, public_path: <<public::binary()>> = path, name: name, compress: true}) do
    host = URI.parse(host)
    Config.update(%{host: host, public_path: host |> URI.merge(public) |> URI.to_string(), index_path: Path.join(path, "#{name}.xml.gz")})
  end
  def pre_work(%{host: <<host::binary()>>, public_path: <<public::binary()>> = path, name: name, compress: false}) do
    host = URI.parse(host)
    Config.update(%{host: host, public_path: host |> URI.merge(public) |> URI.to_string(), index_path: Path.join(path, "#{name}.xml")})
  end

  def post_work(config) do
    case state(config) do
      [{:index, index, _, _}, {:sitemap, sitemap, _, _}] ->
        close(:index, index)
        close(:sitemap, sitemap)
        :ets.insert(:sitemap, {:local, []})
        :ok

      _ ->
        :ok
    end
  end

  def upload(_config), do: :ok

  def add(uri, attr, %{host: host} = config) do
    uri
    |> Sitemap.generate_entry(attr, host)
    |> Sitemap.url()
    |> add(config, state(config))
  end

  def add_to_index(uri, attr, %{host: host} = config) do
    uri
    |> Sitemap.generate_entry(attr, host)
    |> Sitemap.sitemap()
    |> add_to_index(config, state(config))
  end

  for {key, bool, write_opts, ext} <- [{:compress, true, [:write, :compressed], ".xml.gz"}, {:compress, false, [:write], ".xml"}] do
    def new_state(%{:files_path => path, :public_path => public, :name => name, :host => host, unquote(key) => unquote(bool)}) do
      if File.exists?(path), do: File.rm_rf!(path)
      File.mkdir_p(path)
      :ets.insert(:sitemap, {:counter, 1})
      sitemap_path = "#{name}1#{unquote(ext)}"
      sitemap = open!(path, sitemap_path, unquote(write_opts))
      index = open!(path, "#{name}#{unquote(ext)}", unquote(write_opts))

      IO.write(index, [Sitemap.header() | Sitemap.index()])
      IO.write(sitemap, [Sitemap.header() | Sitemap.urlset()])

      content = public |> Path.join(sitemap_path) |> Sitemap.generate_entry([], host) |> Sitemap.sitemap()
      :file.pwrite(index, 294, content)

      state = [{:index, index, 1, 294 + size(content)}, {:sitemap, sitemap, 0, 715}]
      :ets.insert(:sitemap, {:local, state})
      state
    end

    def add(url, %{:max_sitemap_links => max_links, :max_sitemap_files => max_files, :files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)}, [{:index, index, links, i_pos}, {:sitemap, sitemap, max_files, _s_pos}]) when max_links - links == 1  do
      counter = :ets.update_counter(:sitemap, :counter, 1)
      new_index_path = "#{name}#{counter}#{unquote(ext)}"
      new_index = open!(path, new_index_path, unquote(write_opts))
      :file.pwrite(index, i_pos, Sitemap.sitemap(public, new_index_path))
      close(:index, index)
      close(:sitemap, sitemap)
      IO.write(new_index, [Sitemap.header() | Sitemap.index()])

      counter = :ets.update_counter(:sitemap, :counter, 1)
      new_sitemap_path = "#{name}#{counter}#{unquote(ext)}"
      new_sitemap = open!(path, new_sitemap_path, unquote(write_opts))
      content = Sitemap.sitemap(public, new_sitemap_path)
      IO.write(new_sitemap, [Sitemap.header(), Sitemap.urlset()])
      :file.pwrite(new_index, 294, content)
      :file.pwrite(new_sitemap, 715, url)

      :ets.insert(:sitemap, {:local, [{:index, new_index, 1, 294 + size(content)}, {:sitemap, new_sitemap, 0, 715 + size(url)}]})
    end
    def add(url, %{:max_sitemap_links => max_links, :files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)}, [{:index, index, links, i_pos}, {:sitemap, sitemap, entries, s_pos}]) when max_links - links == 1  do
      counter = :ets.update_counter(:sitemap, :counter, 1)
      new_index_path = "#{name}#{counter}#{unquote(ext)}"
      new_index = open!(path, new_index_path, unquote(write_opts))
      :file.pwrite(index, i_pos, Sitemap.sitemap(public, new_index_path))
      close(:index, index)
      IO.write(new_index, [Sitemap.header() | Sitemap.index()])
      :file.pwrite(sitemap, s_pos, url)

      :ets.insert(:sitemap, {:local, [{:index, new_index, 0, 294}, {:sitemap, sitemap, entries + 1, s_pos + size(url)}]})
    end
    def add(url, %{:max_sitemap_files => max_files, :files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)}, [{:index, index, links, i_pos}, {:sitemap, sitemap, max_files, _s_pos}]) do
      close(:sitemap, sitemap)
      counter = :ets.update_counter(:sitemap, :counter, 1)

      new_sitemap_path = "#{name}#{counter}#{unquote(ext)}"
      new_sitemap = open!(path, new_sitemap_path, unquote(write_opts))
      IO.write(new_sitemap, [Sitemap.header(), Sitemap.urlset()])

      :file.pwrite(new_sitemap, 715, url)
      content = Sitemap.sitemap(public, new_sitemap_path)
      :file.pwrite(index, i_pos, Sitemap.sitemap(public, new_sitemap_path))

      :ets.insert(:sitemap, {:local, [{:index, index, links + 1, i_pos + size(content)}, {:sitemap, new_sitemap, 1, 715 + size(url)}]})
    end

    def add_to_index(url, %{:max_sitemap_links => max_links, :files_path => path, :public_path => public, :name => name, unquote(key) => unquote(bool)}, [{:index, index, links, i_pos}, {:sitemap, _sitemap, _entries, _s_pos} = sitemap]) when max_links - links == 1 do
      counter = :ets.update_counter(:sitemap, :counter, 1)
      new_index_path = "#{name}#{counter}#{unquote(ext)}"
      new_index = open!(path, new_index_path, unquote(write_opts))
      :file.pwrite(index, i_pos, Sitemap.sitemap(public, new_index_path))
      close(:index, index)
      :file.pwrite(new_index, 294, url)
      :ets.insert(:sitemap, {:local, [{:index, new_index, 1, 294 + size(url)}, sitemap]})
    end
  end

  def add(url, _config, [{:index, _index, _links, _i_pos} = index, {:sitemap, sitemap, entries, s_pos}]) do
    :file.pwrite(sitemap, s_pos, url)
    :ets.insert(:sitemap, {:local, [index, {:sitemap, sitemap, entries + 1, s_pos + size(url)}]})
  end
  def add_to_index(url, _config, [{:index, index, links, i_pos}, {:sitemap, _sitemap, _entries, _s_pos} = sitemap]) do
    :file.pwrite(index, i_pos, url)
    :ets.insert(:sitemap, {:local, [{:index, index, links + 1, i_pos + size(url)}, sitemap]})
  end

  def ping(urls, %{index_path: path} = config) do
    ping(['http://google.com/ping?sitemap=#{path}', 'http://www.bing.com/webmaster/ping.aspx?sitemap=#{path}' | urls], state(config))
  end
  def ping(urls, [{:index, index, _, _}, {:sitemap, sitemap, _, _}]) do
    close(:index, index)
    close(:sitemap, sitemap)
    ping(urls, [])
  end
  def ping(urls, []) do
    for url <- urls do
      :httpc.request('#{url}')
      IO.puts("Successful ping of #{url}")
    end
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

  defp state(config) do
    case :ets.lookup(:sitemap, :local) do
      []             -> new_state(config)

      [local: []]    -> new_state(config)

      [local: state] -> state
    end
  end

  defp size(iodata) do
    iodata
    |> IO.iodata_to_binary()
    |> byte_size()
  end

  defp open!(path, file, opts) do
    path
    |> Path.join(file)
    |> File.open!(opts)
  end

  defp close(:index, pid) do
    IO.write(pid, "</sitemapindex>")
    File.close(pid)
  end
  defp close(:sitemap, pid) do
    IO.write(pid, "</urlset>\n")
    File.close(pid)
  end
end
