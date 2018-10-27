defmodule Sitemap.GeoTest do
  use ExUnit.Case

  @geo [format: "kml"]
  @expected "
  <geo:geo>
    <geo:format>kml</geo:format>
  </geo:geo>"

  test "new/1" do
    assert IO.iodata_to_binary(Sitemap.Geo.new(@geo)) == @expected
  end
end
