defmodule TdSe.Mixfile do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :td_se,
      version:
        case System.get_env("APP_VERSION") do
          nil -> "7.7.0-local"
          v -> v
        end,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
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
      {:phoenix, "~> 1.7.18"},
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4.4"},
      {:guardian, "~> 2.3.2"},
      {:bodyguard, "~> 2.4.3"},
      {:td_core, git: "https://github.com/Bluetab/td-core.git", tag: "7.8.0"},
      {:credo, "~> 1.7.11", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.5", only: :dev, runtime: false},
      {:mox, "~> 1.2", only: :test},
      {:sobelow, "~> 0.13", only: [:dev, :test]}
    ]
  end
end
