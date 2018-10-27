defmodule SitemapTest do
  use ExUnit.Case

  test "mobile/1" do
    assert Sitemap.mobile(true) == "\n\s\s<mobile:mobile/>"
    assert Sitemap.mobile(false) == []
  end
end

