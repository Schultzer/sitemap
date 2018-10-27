defmodule Sitemap.AlternateTest do
  use ExUnit.Case

  @alternates [href: "http://www.example.de/index.html", lang: "de", nofollow: true, media: "only screen and (max-width: 640px)"]
  @expected "
  <xhtml:link href=\"http://www.example.de/index.html\" hreflang=\"de\" media=\"only screen and (max-width: 640px)\" rel=\"alternate nofollow\"/>"

  test "new/1" do
    assert IO.iodata_to_binary(Sitemap.Alternate.new(@alternates)) == @expected
  end
end
