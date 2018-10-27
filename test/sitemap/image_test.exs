defmodule Sitemap.ImageTest do
  use ExUnit.Case

  @image [loc: "http://example.com/image.jpg",
          caption: "Caption",
          title: "Title",
          license: "https://github.com/ikeikeikeike/sitemap/blob/master/LICENSE",
          geo_location: "Limerick, Ireland"]
  @expected "
  <image:image>
    <image:loc>http://example.com/image.jpg</image:loc>
    <image:caption>Caption</image:caption>
    <image:title>Title</image:title>
    <image:license>https://github.com/ikeikeikeike/sitemap/blob/master/LICENSE</image:license>
    <image:geo_location>Limerick, Ireland</image:geo_location>
  </image:image>"

  test "new/1" do
    assert IO.iodata_to_binary(Sitemap.Image.new(@image)) == @expected
  end
end
