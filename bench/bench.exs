defmodule Bench.FastSitemap do
  use FastSitemap, compress: false

  def simple(range) do
    create host: "https://example.com", files_path: Path.join(__DIR__, "fast_sitemap"), public_path: "sitemaps" do
      for n <- range do
        add "#{n}", lastmod: DateTime.utc_now()
      end
    end
  end

  def complex(range) do
    create host: "https://example.com", files_path: Path.join(__DIR__, "fast_sitemap"), public_path: "sitemaps" do
      for n <- range do
        add "#{n}", lastmod: DateTime.utc_now()
        add "#{n + 1}", news: [
          publication_name: "Example",
          publication_language: "en",
          title: "My Article",
          keywords: "my article, articles about myself",
          stock_tickers: "SAO:PETR3",
          publication_date: "2011-08-22",
          access: "Subscription",
          genres: "PressRelease"
        ]
        add "#{n + 2}", images: [
          loc: "http://example.com/image.jpg",
          caption: "Caption",
          title: "Title",
          license: "https://github.com/ikeikeikeike/sitemap/blob/master/LICENSE",
          geo_location: "Limerick, Ireland",
        ]
        add "#{n + 3}", videos: [
          thumbnail_loc: "http://www.example.com/thumbs/123.jpg",
          title: "Grilling steaks for summer",
          description: "Alkis shows you how to get perfectly done steaks every time",
          content_loc: "http://www.example.com/video123.flv",
          player_loc: "http://www.example.com/videoplayer.swf?video=123",
          allow_embed: true,
          autoplay: true,
          duration: 600,
          expiration_date: "2009-11-05T19:20:30+08:00",
          publication_date: "2007-11-05T19:20:30+08:00",
          rating: 0.5,
          view_count: 1000,
          tags: ~w(tag1 tag2 tag3),
          tag: "tag4",
          category: "Category",
          family_friendly: true,
          restriction: "IE GB US CA",
          relationship: true,
          gallery_loc: "http://cooking.example.com",
          gallery_title: "Cooking Videos",
          price: "1.99",
          price_currency: "EUR",
          price_type: "own",
          price_resolution: "HD",
          uploader: "GrillyMcGrillerson",
          uploader_info: "http://www.example.com/users/grillymcgrillerson",
          live: true,
          requires_subscription: false
        ]
        add "#{n + 4}", alternates: [
          href: "http://www.example.de/index.html",
          lang: "de",
          nofollow: true,
          media: "only screen and (max-width: 640px)"
        ]
        add "#{n + 5}", geo: [
          format: "kml"
        ]
        add "#{n + 6}", priority: 0.5, changefreq: :hourly, mobile: true

        add "#{n + 7}", pagemap: [dataobjects: [[type: "document", id: "hibachi", attributes: [[name: "name", value: "Dragon"], [name: "review", value: "3.5"]]]]]
      end
    end
  end
end

defmodule Bench.Sitemap do
  use Sitemap, compress: false

  def simple(range) do
    create host: "https://example.com", files_path: Path.join(__DIR__, "fast_sitemap"), public_path: "sitemaps" do
      for n <- range do
        add "#{n}", lastmod: DateTime.utc_now()
      end
    end
  end

  def complex(range) do
    create host: "https://example.com/", files_path: Path.join(__DIR__, "sitemap"), public_path: "sitemaps/" do
      for n <- range do
        add "#{n}", lastmod: DateTime.utc_now()
        add "#{n + 1}", news: [
          publication_name: "Example",
          publication_language: "en",
          title: "My Article",
          keywords: "my article, articles about myself",
          stock_tickers: "SAO:PETR3",
          publication_date: "2011-08-22",
          access: "Subscription",
          genres: "PressRelease"
        ]
        add "#{n + 2}", images: [
          loc: "http://example.com/image.jpg",
          caption: "Caption",
          title: "Title",
          license: "https://github.com/ikeikeikeike/sitemap/blob/master/LICENSE",
          geo_location: "Limerick, Ireland",
        ]
        add "#{n + 3}", videos: [
          thumbnail_loc: "http://www.example.com/thumbs/123.jpg",
          title: "Grilling steaks for summer",
          description: "Alkis shows you how to get perfectly done steaks every time",
          content_loc: "http://www.example.com/video123.flv",
          player_loc: "http://www.example.com/videoplayer.swf?video=123",
          allow_embed: true,
          autoplay: true,
          duration: 600,
          expiration_date: "2009-11-05T19:20:30+08:00",
          publication_date: "2007-11-05T19:20:30+08:00",
          rating: 0.5,
          view_count: 1000,
          tags: ~w(tag1 tag2 tag3),
          tag: "tag4",
          category: "Category",
          family_friendly: true,
          restriction: "IE GB US CA",
          relationship: true,
          gallery_loc: "http://cooking.example.com",
          gallery_title: "Cooking Videos",
          price: "1.99",
          price_currency: "EUR",
          price_type: "own",
          price_resolution: "HD",
          uploader: "GrillyMcGrillerson",
          uploader_info: "http://www.example.com/users/grillymcgrillerson",
          live: true,
          requires_subscription: false
        ]
        add "#{n + 4}", alternates: [
          href: "http://www.example.de/index.html",
          lang: "de",
          nofollow: true,
          media: "only screen and (max-width: 640px)"
        ]
        add "#{n + 5}", geo: [
          format: "kml"
        ]
        add "#{n + 6}", priority: 0.5, changefreq: "hourly", mobile: true

        add "#{n + 7}", pagemap: [
          dataobjects: [
            [type: "document", id: "hibachi", attributes: [[name: "name", value: "Dragon"], [name: "review", value: "3.5"]]]
          ]
        ]
      end
    end
  end
end


Benchee.run([
  {"fast_sitemap - simple", fn -> Bench.FastSitemap.simple(1..10_000) end},
  {"sitemap - simple", fn -> Bench.Sitemap.simple(1..10_000) end},
  {"fast_sitemap - complex", fn -> Bench.FastSitemap.complex(1..10_000) end},
  {"sitemap - complex", fn -> Bench.Sitemap.complex(1..10_000) end},
  ],
  time: 10,
  memory_time: 2,
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.Console
  ]
)
