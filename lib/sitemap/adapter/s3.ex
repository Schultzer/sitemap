defmodule Sitemap.Adapter.S3 do
  @moduledoc false
  alias Sitemap.Adapter.Local
  use GenServer

  @doc false
  @spec add(binary(), keyword()) :: :ok
  def add(url, opts) do
    GenServer.cast(Local, {:sitemap_file, url, opts})
  end

  @doc false
  @spec add_to_index(binary(), keyword()) :: :ok
  def add_to_index(url, opts) do
    GenServer.cast(Local, {:index_file, url, opts})
  end

  @doc false
  @spec start_link(map()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(config) do
    GenServer.start_link(Local, config, name: Local)
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

  @doc false
  @spec ping([binary()]) :: :ok
  def ping(urls) do
    GenServer.stop(__MODULE__, {:shutdown, urls})
  end

  def init(config) do
    {:ok, config}
  end

  def terminate({:shutdown, urls}, %{index_path: path} = config) do
    case GenServer.whereis(Local) do
      nil ->
        upload_to_s3(config)

      _   ->
        GenServer.stop(Local)
        upload_to_s3(config)
    end
    for url <- ['http://google.com/ping?sitemap=#{path}', 'http://www.bing.com/webmaster/ping.aspx?sitemap=#{path}' | urls] do
      :httpc.request('#{url}')
      IO.puts("Successful ping of #{url}")
    end
  end


  def terminate(_reason, config) do
    case GenServer.whereis(Local) do
      nil ->
        upload_to_s3(config)

      _   ->
        GenServer.stop(Local)
        upload_to_s3(config)
    end
  end

  defp upload_to_s3(%{files_path: path, bucket: bucket} = config) do
     for file <- File.ls!(path) do
      path
      |> Path.join(file)
      |> ExAws.S3.Upload.stream_file()
      |> ExAws.S3.upload(bucket, Path.join(Path.dirname(path), file))
      |> ExAws.request(config[:aws_opts] || [])
     end

     tmp_path = Path.join(:code.priv_dir(:sitemap), "tmp")
     if File.exists?(tmp_path), do: File.rm_rf!(tmp_path)
  end
end
