defmodule Sitemap.MixProject do
  use Mix.Project

  @version "1.0.0-rc.0"

  def project do
    [
      app: :fast_sitemap,
      version: @version,
      elixir: "~> 1.7",
      name: "Sitemap",
      source_url: "https://github.com/schultzer/sitemap",
      description: description(),
      package: package(),
      docs: docs(),
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  defp description do
    """
    Efficient and fast generation of sitemaps.
    """
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:benchee, "~> 0.13.2", only: :bench},
      {:benchee_html, "~> 0.5.0", only: :bench},
      {:sitemap, "~> 1.0", only: :bench},
    ]
  end

  defp package do
    [
      maintainers: ["Benjamin Schultzer"],
      licenses: ~w(MIT),
      links: links(),
      files: ~w(lib config mix.exs README* CHANGELOG* LICENSE*)
    ]
  end

  def docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ~w(README.md CHANGELOG.md)
    ]
  end

  def links do
    %{
      "GitHub"    => "https://github.com/schultzer/sitemap",
      "Readme"    => "https://github.com/schultzer/sitemap/blob/v#{@version}/README.md",
      "Changelog" => "https://github.com/schultzer/sitemap/blob/v#{@version}/CHANGELOG.md"
    }
  end

end
