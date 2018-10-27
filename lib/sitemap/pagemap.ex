defmodule Sitemap.PageMap do
  @moduledoc false

  @doc false
  @spec new(keyword()) :: iodata()
  def new(dataobjects: []), do: []
  def new(dataobjects: dataobjects) do
    dataobjects
    |> Enum.map(&Map.new/1)
    |> create(["\n\s\s<PageMap>"])
  end
  def new([]), do: []

  defp create([], ["\n\s\s<PageMap>"]), do: []
  defp create([], [["\n\s\s<PageMap>"] | _] = acc), do: [acc | "\n\s\s</PageMap>"]
  defp create([%{attributes: []} | rest], acc), do: create(rest, acc)
  defp create([%{type: type, id: id, attributes: [[{:name, _}, {:value, _}] | _] = attributes} | rest], acc) do
    create(rest, [acc, "\n\s\s\s\s<DataObject id=\"#{id}\" type=\"#{type}\">", attributes(attributes) | "\n\s\s\s\s</DataObject>"])
  end
  defp create([%{type: type, attributes: [{:name, _}, {:value, _} | _] = attributes} | rest], acc) do
    create(rest, [acc, "\n\s\s\s\s<DataObject type=\"#{type}\">", attributes(attributes) | "\n\s\s\s\s</DataObject>"])
  end
  defp create([%{id: id, attributes: [{:name, _}, {:value, _} | _] = attributes} | rest], acc) do
    create(rest, [acc, "\n\s\s\s\s<DataObject id=\"#{id}\">", attributes(attributes) | "\n\s\s\s\s</DataObject>"])
  end
  defp create([_ | rest], acc), do: create(rest, acc)

  defp attributes(attr, acc \\ [])
  defp attributes([], acc), do: acc
  defp attributes([[name: name, value: value] | rest], acc) do
    attributes(rest, [acc | "\n\s\s\s\s\s\s<Attribute name=\"#{name}\">#{value}</Attribute>"])
  end
  defp attributes([_ | rest], acc), do: attributes(rest, acc)
end
