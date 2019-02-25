defmodule Pundit.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :pundit,
      aliases: aliases(),
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Simple authorization helpers for Elixir structs",
      package: package(),
      source_url: "https://github.com/bmuller/pundit-elixir",
      docs: [
        source_ref: "v#{@version}",
        main: "Pundit",
        formatters: ["html", "epub"]
      ]
    ]
  end

  defp aliases do
    [
      test: [
        "format --check-formatted",
        "test",
        "credo"
      ]
    ]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Brian Muller"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/bmuller/pundit-elixir"}
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
      {:ex_doc, "~> 0.18", only: :dev},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.0", optional: true}
    ]
  end
end
