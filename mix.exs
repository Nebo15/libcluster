defmodule Cluster.Mixfile do
  use Mix.Project

  @version "1.1.3"

  def project do
    [app: :skycluster,
     description: "Automatic Erlang cluster formation, messaging and management for Elixir/Erlang applications.",
     package: package(),
     version: @version,
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test],
     docs: [source_ref: "v#\{@version\}", main: "readme", extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :inets, :poison, :confex],
     mod: {Cluster.App, []}]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:confex, ">= 0.0.0"},
     {:poison, "~> 3.1"},
     {:ex_doc, ">= 0.0.0", only: [:dev, :test]},
     {:excoveralls, "~> 0.5", only: [:dev, :test]},
     {:dogma, "> 0.1.0", only: [:dev, :test]},
     {:credo, ">= 0.4.8", only: [:dev, :test]}]
  end

  defp package do
    [contributors: ["Nebo #15", "Paul Schoenfelder"],
     maintainers: ["Nebo #15"],
     licenses: ["LISENSE.md"],
     links: %{github: "https://github.com/Nebo15/skycluster"},
     files: ~w(lib LICENSE.md mix.exs README.md)]
  end
end
