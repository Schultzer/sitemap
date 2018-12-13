if Code.ensure_compiled?(ExAws.S3) do
  defmodule Sitemap.Adapter.S3 do
    @moduledoc false
    use Sitemap.Adapter
    alias Sitemap.Config

    def pre_work(%{host: <<host::binary()>>, public_path: <<public::binary()>>, files_path: <<path::binary()>>, bucket: bucket, public_path: path, name: name, compress: true} = config) when byte_size(bucket) > 0 do
      host = URI.parse(host)
      Config.update(%{config | host: host, public_path: host |> URI.merge(public) |> URI.to_string(), files_path: Path.join(tmp_dir(), path), index_path: Path.join(path, "#{name}.xml.gz")})
    end
    def pre_work(%{host: <<host::binary()>>, public_path: <<public::binary()>>, files_path: <<path::binary()>>, bucket: bucket, public_path: path, name: name, compress: false} = config) when byte_size(bucket) > 0 do
      host = URI.parse(host)
      Config.update(%{config | host: host, public_path: host |> URI.merge(public) |> URI.to_string(), files_path: Path.join(tmp_dir(), path), index_path: Path.join(path, "#{name}.xml")})
    end
    def pre_work(config), do: raise ArgumentError, "No bucket was configured #{inspect config}"

    def post_work(config) do
      upload(config)
    end

    def upload(%{bucket: bucket, files_path: path} = config) do
      for file <- File.ls!(path) do
        path
        |> Path.join(file)
        |> ExAws.S3.Upload.stream_file()
        |> ExAws.S3.upload(bucket, Path.join(Path.dirname(path), file))
        |> ExAws.request(config[:aws_opts] || [])

        IO.puts("Uploaded #{file} to #{bucket}")
      end

      tmp_path = Path.join(:code.priv_dir(:sitemap), "tmp")
      if File.exists?(tmp_path), do: File.rm_rf!(tmp_path)
    end
  end
end
