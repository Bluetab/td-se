defmodule TdSe.Mixfile do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :td_se,
      version:
        case System.get_env("APP_VERSION") do
          nil -> "3.0.0-local"
          v -> v
        end,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers() ++ [:phoenix_swagger],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TdSe.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:jason, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:cabbage, git: "https://github.com/Bluetab/cabbage", tag: "v0.3.7-alpha"},
      {:httpoison, "~> 1.0"},
      {:distillery, "~> 2.0", runtime: false},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:guardian, "~> 1.0"},
      {:corsica, "~> 1.0"},
      {:phoenix_swagger, "~> 0.8.0"},
      {:ex_json_schema, "~> 0.5"},
      {:json_diff, "~> 0.1.0"},
      {:csv, "~> 2.0.0"},
      {:td_cache, git: "https://github.com/Bluetab/td-cache.git", tag: "3.0.0"}
    ]
  end

  defp aliases do
    [
      test: ["Se.EsInit", "test", "Se.EsClean"]
    ]
  end
end
