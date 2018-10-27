defmodule Sitemap.VideoTest do
  use ExUnit.Case

  @video [title: "Grilling steaks for summer",
          description: "Alkis shows you how to get perfectly done steaks every time",
          content_loc: "http://www.example.com/video123.flv",
          player_loc: "http://www.example.com/videoplayer.swf?video=123",
          allow_embed: true,
          autoplay: true,
          duration: 600,
          rating: 0.5,
          view_count: 1000,
          tags: ~w(tag1 tag2 tag3),
          tag: "tag4",
          category: "Category",
          family_friendly: true,
          restriction: "IE GB US CA",
          relationship: true,
          thumbnail_loc: "http://www.example.com/thumbs/123.jpg",
          gallery_loc: "http://cooking.example.com",
          gallery_title: "Cooking Videos",
          expiration_date: "2009-11-05T19:20:30+08:00",
          publication_date: "2007-11-05T19:20:30+08:00",
          uploader: "GrillyMcGrillerson",
          uploader_info: "http://www.example.com/users/grillymcgrillerson",
          price: "1.99",
          price_currency: "EUR",
          price_type: "own",
          price_resolution: "HD",
          live: true,
          requires_subscription: false]
  @expected "
  <video:video>
    <video:title>Grilling steaks for summer</video:title>
    <video:description>Alkis shows you how to get perfectly done steaks every time</video:description>
    <video:player_loc allow_embed=\"yes\" autoplay=\"ap=1\">http://www.example.com/videoplayer.swf?video=123</video:player_loc>
    <video:content_loc>http://www.example.com/video123.flv</video:content_loc>
    <video:thumbnail_loc>http://www.example.com/thumbs/123.jpg</video:thumbnail_loc>
    <video:duration>600</video:duration>
    <video:gallery_loc title=\"Cooking Videos\">http://cooking.example.com</video:gallery_loc>
    <video:rating>0.5</video:rating>
    <video:view_count>1000</video:view_count>
    <video:expiration_date>2009-11-05T19:20:30+08:00</video:expiration_date>
    <video:publication_date>2007-11-05T19:20:30+08:00</video:publication_date>
    <video:tag>tag1</video:tag>
    <video:tag>tag2</video:tag>
    <video:tag>tag3</video:tag>
    <video:tag>tag4</video:tag>
    <video:category>Category</video:category>
    <video:family_friendly>yes</video:family_friendly>
    <video:restriction relationship=\"allow\">IE GB US CA</video:restriction>
    <video:uploader info=\"http://www.example.com/users/grillymcgrillerson\">GrillyMcGrillerson</video:uploader>
    <video:price currency=\"EUR\" resolution=\"HD\" type=\"own\">1.99</video:price>
    <video:live>yes</video:live>
    <video:requires_subscription>no</video:requires_subscription>
  </video:video>"

  test "new/1" do
    assert IO.iodata_to_binary(Sitemap.Video.new(@video)) == @expected
  end
end
