defmodule Sitemap.Video do
  @moduledoc false

  @start "\n\s\s<video:video>"

  @doc false
  @spec new(keyword()) :: iodata()
  def new([{_, _} | _] = video), do: create(16, Map.new(video))
  def new([video | rest]) when is_list(video) do
    [new(video) | new(rest)]
  end

  defp create(16, %{thumbnail_loc: thumb, title: title, description: desc, player_loc: player, allow_embed: allow, autoplay: autoplay, content_loc: content} = data) do
    allow = if allow == true, do: "yes", else: "no"
    autoplay = if autoplay == true, do: "ap=1", else: "ap=0"
    create(15, data, [@start | "\n\s\s\s\s<video:title>#{title}</video:title>\n\s\s\s\s<video:description>#{desc}</video:description>\n\s\s\s\s<video:player_loc allow_embed=\"#{allow}\" autoplay=\"#{autoplay}\">#{player}</video:player_loc>\n\s\s\s\s<video:content_loc>#{content}</video:content_loc>\n\s\s\s\s<video:thumbnail_loc>#{thumb}</video:thumbnail_loc>"])
  end
  defp create(16, %{thumbnail_loc: thumb, title: title, description: desc, player_loc: player, allow_embed: allow, content_loc: content} = data) do
    allow = if allow == true, do: "yes", else: "no"
    create(15, data, [@start | "\n\s\s\s\s<video:title>#{title}</video:title>\n\s\s\s\s<video:description>#{desc}</video:description>\n\s\s\s\s<video:player_loc allow_embed=\"#{allow}\">#{player}</video:player_loc>\n\s\s\s\s<video:content_loc>#{content}</video:content_loc>\n\s\s\s\s<video:thumbnail_loc>#{thumb}</video:thumbnail_loc>"])
  end
  defp create(16, %{thumbnail_loc: thumb, title: title, description: desc, player_loc: player, autoplay: autoplay, content_loc: content} = data) do
    autoplay = if autoplay == true, do: "ap=1", else: "ap=0"
    create(15, data, [@start | "\n\s\s\s\s<video:title>#{title}</video:title>\n\s\s\s\s<video:description>#{desc}</video:description>\n\s\s\s\s<video:player_loc autoplay=\"#{autoplay}\">#{player}</video:player_loc>\n\s\s\s\s<video:content_loc>#{content}</video:content_loc>\n\s\s\s\s<video:thumbnail_loc>#{thumb}</video:thumbnail_loc>"])
  end
  defp create(16, %{thumbnail_loc: thumb, title: title, description: desc, player_loc: player, allow_embed: allow, autoplay: autoplay} = data) do
    allow = if allow == true, do: "yes", else: "no"
    autoplay = if autoplay == true, do: "ap=1", else: "ap=0"
    create(15, data, [@start | "\n\s\s\s\s<video:title>#{title}</video:title>\n\s\s\s\s<video:description>#{desc}</video:description>\n\s\s\s\s<video:player_loc allow_embed=\"#{allow}\" autoplay=\"#{autoplay}\">#{player}</video:player_loc>\n\s\s\s\s<video:thumbnail_loc>#{thumb}</video:thumbnail_loc>"])
  end
  defp create(16, %{thumbnail_loc: thumb, title: title, description: desc, player_loc: player, allow_embed: allow} = data) do
    allow = if allow == true, do: "yes", else: "no"
    create(15, data, [@start | "\n\s\s\s\s<video:title>#{title}</video:title>\n\s\s\s\s<video:description>#{desc}</video:description>\n\s\s\s\s<video:player_loc allow_embed=\"#{allow}\">#{player}</video:player_loc>\n\s\s\s\s<video:thumbnail_loc>#{thumb}</video:thumbnail_loc>"])
  end
  defp create(16, %{thumbnail_loc: thumb, title: title, description: desc, player_loc: player, autoplay: autoplay} = data) do
    autoplay = if autoplay == true, do: "ap=1", else: "ap=0"
    create(15, data, [@start | "\n\s\s\s\s<video:title>#{title}</video:title>\n\s\s\s\s<video:description>#{desc}</video:description>\n\s\s\s\s<video:player_loc autoplay=\"#{autoplay}\">#{player}</video:player_loc>\n\s\s\s\s<video:thumbnail_loc>#{thumb}</video:thumbnail_loc>"])
  end
  defp create(16, %{thumbnail_loc: thumb, title: title, description: desc, content_loc: content} = data) do
    create(15, data, [@start | "\n\s\s\s\s<video:title>#{title}</video:title>\n\s\s\s\s<video:description>#{desc}</video:description>\n\s\s\s\s<video:content_loc>#{content}</video:content_loc>\n\s\s\s\s<video:thumbnail_loc>#{thumb}</video:thumbnail_loc>"])
  end
  defp create(16, %{}), do: []
  defp create(0, _data, acc), do: [acc | "\n\s\s</video:video>"]

  for {key, pos} <- [duration: 15, rating: 13, view_count: 12, category: 8] do
    defp create(unquote(pos), %{unquote(key) => value} = data, acc) do
      key = "#{unquote(key)}"
      create(unquote(pos) - 1, data, [acc | "\n\s\s\s\s<video:#{key}>#{value}</video:#{key}>"])
    end
  end
  for {key, pos} <- [expiration_date: 11, publication_date: 10] do
    defp create(unquote(pos), %{unquote(key) => <<_::binary-size(4), ?-, _::binary-size(2), ?-, _::binary-size(2), _::binary()>> = value} = data, acc) do
      key = "#{unquote(key)}"
      create(unquote(pos) - 1, data, [acc | "\n\s\s\s\s<video:#{key}>#{value}</video:#{key}>"])
    end
    defp create(unquote(pos), %{unquote(key) => %datetime{} = value} = data, acc) when datetime in [Date, DateTime, NaiveDateTime] do
      key = "#{unquote(key)}"
      create(unquote(pos) - 1, data, [acc | "\n\s\s\s\s<video:#{key}>#{datetime.to_iso8601(value)}</video:#{key}>"])
    end
  end
  for {key, value} <- [true: "yes", false: "no"] do
    defp create(7, %{family_friendly: unquote(key)} = data, acc) do
      create(6, data, [acc | "\n\s\s\s\s<video:family_friendly>#{unquote(value)}</video:family_friendly>"])
    end
    defp create(3, %{live: unquote(key)} = data, acc) do
      create(2, data, [acc | "\n\s\s\s\s<video:live>#{unquote(value)}</video:live>"])
    end
    defp create(2, %{requires_subscription: unquote(key)} = data, acc) do
      create(1, data, [acc | "\n\s\s\s\s<video:requires_subscription>#{unquote(value)}</video:requires_subscription>"])
    end
  end

  defp create(5, %{uploader: value, uploader_info: info} = data, acc) do
    create(4, data, [acc | "\n\s\s\s\s<video:uploader info=\"#{info}\">#{value}</video:uploader>"])
  end
  defp create(5, %{uploader: value} = data, acc) do
    create(4, data, [acc | "\n\s\s\s\s<video:uploader>#{value}</video:uploader>"])
  end
  defp create(9, %{tags: tags, tag: tag} = data, acc) do
    tags = for tag <- tags, do: "\n\s\s\s\s<video:tag>#{tag}</video:tag>"
    create(8, data, [acc | [ tags | "\n\s\s\s\s<video:tag>#{tag}</video:tag>"]])
  end
  defp create(9, %{tags: tags} = data, acc) do
    tags = for tag <- tags, do: "\n\s\s\s\s<video:tag>#{tag}</video:tag>"
    create(8, data, [acc | tags])
  end
  defp create(9, %{tag: tag} = data, acc) do
    create(8, data, [acc | "\n\s\s\s\s<video:tag>#{tag}</video:tag>"])
  end
  defp create(14, %{gallery_loc: value, gallery_title: title} = data, acc) do
    create(13, data, [acc | "\n\s\s\s\s<video:gallery_loc title=\"#{title}\">#{value}</video:gallery_loc>"])
  end
  defp create(14, %{gallery_loc: value} = data, acc) do
    create(13, data, [acc | "\n\s\s\s\s<video:gallery_loc>#{value}</video:gallery_loc>"])
  end
  defp create(4, %{price: price, price_currency: currency, price_type: type, price_resolution: resolution} = data, acc) do
    create(3, data, [acc | "\n\s\s\s\s<video:price currency=\"#{currency}\" resolution=\"#{resolution}\" type=\"#{type}\">#{price}</video:price>"])
  end
  defp create(4, %{price: price, price_currency: currency, price_resolution: resolution} = data, acc) do
    create(3, data, [acc | "\n\s\s\s\ss<video:price currency=\"#{currency}\" resolution=\"#{resolution}\">#{price}</video:price>"])
  end
  defp create(4, %{price: price, price_currency: currency, price_type: type} = data, acc) do
    create(3, data, [acc | "\n\s\s\s\s<video:price currency=\"#{currency}\" type=\"#{type}\">#{price}</video:price>"])
  end
  defp create(4, %{price: price, price_currency: currency} = data, acc) do
    create(3, data, [acc | "\n\s\s\s\s<video:price currency=\"#{currency}\">#{price}</video:price>"])
  end
  defp create(6, %{restriction: restriction, relationship: true} = data, acc) do
    create(5, data, [acc | "\n\s\s\s\s<video:restriction relationship=\"allow\">#{restriction}</video:restriction>"])
  end
  defp create(6, %{restriction: restriction, relationship: _} = data, acc) do
    create(5, data, [acc | "\n\s\s\s\s<video:restriction relationship=\"deny\">#{restriction}</video:restriction>"])
  end
  for {platform, relationship, bool, value} <- [{:platform, :relationship, true, "allowed"}, {:platform, :relationship, false, "deny"}] do
    for type <- ~w(web mobile tv) do
      defp create(1, %{unquote(platform) => unquote(type), unquote(relationship) => unquote(bool)} = data, acc) do
        create(0, data, [acc | "\n\s\s\s\s<video:platform relationship=\"#{unquote(value)}\">#{unquote(type)}</video:platform>"])
      end
    end
  end
  defp create(1, %{platform: type, relationship: relationship} = data, acc) when type in ~w(tv web mobile) do
    relationship = if relationship, do: "allowed", else: "deny"
    create(0, data, [acc | "\n\s\s\s\s<video:platform relationship=\"#{relationship}\">#{type}</video:platform>"])
  end
  defp create(1, %{platform: type, relationship: relationship} = data, acc) when is_list(type) do
    case type |> Enum.take_while(&(&1 in ~w(tv web mobile))) |> Enum.join(" ") do
      ""   -> create(0, data, acc)

      type ->
        relationship = if relationship, do: "allowed", else: "deny"
        create(0, data, [acc | "\n\s\s\s\s<video:platform relationship=\"#{relationship}\">#{type}</video:platform>"])
    end
  end
  defp create(pos, data, acc), do: create(pos - 1, data, acc)
end
