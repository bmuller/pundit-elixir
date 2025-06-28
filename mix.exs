defmodule Pundit.MixProject do
  use Mix.Project

  @version "1.1.0"
  @source_url "https://github.com/bmuller/pundit-elixir"

  def project do
    [
      app: :pundit,
      aliases: aliases(),
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Simple authorization helpers for Elixir structs",
      package: package(),
      source_url: @source_url,
      docs: docs()
    ]
  end

  def cli do
    [preferred_envs: [test: :test, "ci.test": :test]]
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      formatters: ["html"],
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end

  defp aliases do
    [
      "ci.test": [
        "format --check-formatted",
        "test",
        "credo"
      ]
    ]
  end

  def package do
    [
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      maintainers: ["Brian Muller"],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
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
      {:ecto, "~> 3.0", optional: true},
      {:ex_doc, "~> 0.28", only: :dev},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false}
    ]
  end
end
