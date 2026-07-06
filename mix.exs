defmodule DtsBuddy.MixProject do
  use Mix.Project

  def project do
    [
      app: :dts_buddy,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      source_url: @source_url,
      docs: docs(),
      deps: deps()
    ]
  end

  defp description do
    "An helper library to compile and load device tree overlays (DTBOs) at runtime on Nerves/Linux."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lucassifoni/dts-buddy"},
      files: ~w(lib sample_dt.dts mix.exs README.md LICENSE .formatter.exs)
    ]
  end

  defp docs do
    [
      main: "DtsBuddy",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "0.31.1", only: :dev, runtime: false},
      {:credo, "1.7.5", only: :dev, runtime: false}
    ]
  end
end
