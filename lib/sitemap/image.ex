defmodule Sitemap.Image do
  @moduledoc false

  @doc false
  @spec new(keyword()) :: iodata()
  def new([{_, _} | _] = images), do: create(images, Map.new(images))
  def new([image | rest]) when is_list(image) do
    [new(image) | new(rest)]
  end

  defp create(images, %{loc: loc} = data) do
    create(images, data, ["\n\s\s<image:image>\n\s\s\s\s<image:loc>#{loc}</image:loc>"])
  end
  defp create(_images, %{}), do: []

  defp create([], _data, acc), do: [acc | "\n\s\s</image:image>"]
  for tag <- ~w(caption title license geo_location)a do
    defp create([{unquote(tag), value} | rest], data, acc) do
      key = "#{unquote(tag)}"
      create(rest, data, [acc | ["\n\s\s\s\s<image:", key, ?>, "#{value}", "</image:", key, ?>]])
    end
  end
  defp create([_ | rest], data, acc), do: create(rest, data, acc)
end
