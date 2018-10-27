defmodule Sitemap.Alternate do
  @moduledoc false

  @doc false
  @spec new(keyword()) :: iodata()
  def new(alternates), do: create(Map.new(alternates), 4, ["\n\s\s<xhtml:link"])

  defp create(_alt, 0, ["\n\s\s<xhtml:link"]), do: []
  defp create(_alt, 0, acc), do: [acc | "/>"]
  defp create(%{href: value} = alt, 4, acc) do
    create(alt, 3, [acc | "\shref=\"#{URI.to_string(URI.parse(value))}\""])
  end
  defp create(%{lang: value} = alt, 3, acc) do
    create(alt, 2, [acc | "\shreflang=\"#{value}\""])
  end
  defp create(%{media: value} = alt, 2, acc) do
    create(alt, 1, [acc | "\smedia=\"#{value}\""])
  end
  defp create(%{nofollow: true} = alt, 1, acc) do
    create(alt, 0, [acc | "\srel=\"alternate nofollow\""])
  end
  defp create(%{nofollow: false} = alt, 1, acc) do
    create(alt, 0, [acc | "\srel=\"alternate\""])
  end
  defp create(alt, pos, acc) do
    create(alt, pos - 1, acc)
  end
end
