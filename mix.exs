defmodule TdSe.Mixfile do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :td_se,
      version:
        case System.get_env("APP_VERSION") do
          nil -> "6.4.0-local"
          v -> v
        end,
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        td_se: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent],
          steps: [:assemble, &copy_bin_files/1, :tar]
        ]
      ]
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

  defp copy_bin_files(release) do
    File.cp_r("rel/bin", Path.join(release.path, "bin"))
    release
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_view, "~> 2.0"},
      {:plug_cowboy, "~> 2.1"},
      {:jason, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:httpoison, "~> 1.6"},
      {:bodyguard, "~> 2.4"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:guardian, "~> 2.0"},
      {:corsica, "~> 1.0"},
      {:ex_json_schema, "~> 0.7.3"},
      {:json_diff, "~> 0.1.0"},
      {:ex_machina, "~> 2.3", only: :test},
      {:td_cache, git: "https://github.com/Bluetab/td-cache.git", tag: "6.3.0"},
      {:td_cluster,
       git: "https://github.com/Bluetab/td-cluster.git", tag: "5.19.0", override: true},
      {:td_core, git: "https://github.com/Bluetab/td-core.git", tag: "6.4.0"},
      {:mox, "~> 1.0", only: :test},
      {:sobelow, "~> 0.13", only: [:dev, :test]}
    ]
  end

  defp aliases do
    []
  end
end
