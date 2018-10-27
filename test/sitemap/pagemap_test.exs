defmodule Sitemap.PageMapTest do
  use ExUnit.Case

  @pagemap [dataobjects: [[type: "document", id: "hibachi", attributes: [[name: "name", value: "Dragon"], [name: "review", value: "3.5"]]]]]
  @expected "
  <PageMap>
    <DataObject id=\"hibachi\" type=\"document\">
      <Attribute name=\"name\">Dragon</Attribute>
      <Attribute name=\"review\">3.5</Attribute>
    </DataObject>
  </PageMap>"

  test "new/1" do
    assert IO.iodata_to_binary(Sitemap.PageMap.new(@pagemap)) == @expected
  end
end
