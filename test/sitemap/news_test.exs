defmodule Sitemap.NewsTest do
  use ExUnit.Case

  @news [publication_name: "Example",
         publication_language: "en",
         title: "My Article",
         access: "Subscription",
         genres: "PressRelease",
         keywords: "my article, articles about myself",
         stock_tickers: "SAO:PETR3",
         publication_date: "2011-08-22"]
  @expected "
  <news:news>
    <news:publication>
      <news:name>Example</news:name>
      <news:language>en</news:language>
    </news:publication>
    <news:title>My Article</news:title>
    <news:access>Subscription</news:access>
    <news:genres>PressRelease</news:genres>
    <news:keywords>my article, articles about myself</news:keywords>
    <news:stock_tickers>SAO:PETR3</news:stock_tickers>
    <news:publication_date>2011-08-22</news:publication_date>
  </news:news>"

  test "new/1" do
    assert IO.iodata_to_binary(Sitemap.News.new(@news)) == @expected
  end
end
