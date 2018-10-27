defmodule Sitemap.News do
  @moduledoc false

  @doc false
  @spec new(keyword()) :: iodata()
  def new([{_, _} | _] = news), do: create(news, Map.new(news))
  def new([news | rest]) when is_list(news) do
    [new(news) | new(rest)]
  end

  defp create(news, %{publication_name: name, publication_language: lang, title: title} = data) do
    create(news, data, ["\n\s\s<news:news>\n\s\s\s\s<news:publication>\n\s\s\s\s\s\s<news:name>#{name}</news:name>\n\s\s\s\s\s\s<news:language>#{lang}</news:language>\n\s\s\s\s</news:publication>\n\s\s\s\s<news:title>#{title}</news:title>"])
  end
  defp create(_news, %{}), do: []

  defp create([], _data, acc), do: [acc | "\n\s\s</news:news>"]
  defp create([{:publication_date, %datetime{} = value} | rest], data, acc) when datetime in [DateTime, NaiveDateTime] do
    value = value |> datetime.to_date() |> Date.to_iso8601()
    create(rest, data, [acc | ["\n\s\s\s\s<news:publication_date>#{value}</news:publication_date>"]])
  end
  defp create([{:publication_date, %Date{} = value} | rest], data, acc) do
    create(rest, data, [acc | ["\n\s\s\s\s<news:publication_date>#{Date.to_iso8601(value)}</news:publication_date>"]])
  end
  defp create([{:publication_date, <<_::binary-size(4), ?-, _::binary-size(2), ?-,  _::binary-size(2)>> = value} | rest], data, acc) do
    create(rest, data, [acc | ["\n\s\s\s\s<news:publication_date>#{value}</news:publication_date>"]])
  end
  for tag <- ~w(access genres keywords stock_tickers)a do
    defp create([{unquote(tag), value} | rest], data, acc) do
      key = "#{unquote(tag)}"
      create(rest, data, [acc | "\n\s\s\s\s<news:#{key}>#{value}</news:#{key}>"])
    end
  end
  defp create([{_, _} | rest], data, acc) do
    create(rest, data, acc)
  end
end
