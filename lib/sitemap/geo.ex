defmodule Sitemap.Geo do
  @moduledoc false

  @doc false
  @spec new(keyword()) :: iodata()
  def new(geo), do: create(geo, ["\n\s\s<geo:geo>"])

  defp create([], ["\n\s\s<geo:geo>"]), do: []
  defp create([], acc), do: [acc | "\n\s\s</geo:geo>"]
  defp create([{:format, value} | rest], acc) do
    create(rest, [acc | "\n\s\s\s\s<geo:format>#{value}</geo:format>"])
  end
  defp create([{_, _} | rest], acc) do
    create(rest, acc)
  end
end
