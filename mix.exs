defmodule Defectoscope.MixProject do
  use Mix.Project

  def project do
    [
      app: :defectoscope,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env()
    ]
  end

  # Run "mix help compile.app" to learn about applications
  def application do
    [
      mod: {Defectoscope.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies
  defp deps do
    [
      {:plug, "~> 1.15"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.4.14"},
      # Testing dependencies
      {:excoveralls, "~> 0.18", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test]},
      {:lexical_credo, "~> 0.1.0", only: [:dev, :test]}
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp preferred_cli_env() do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.cobertura": :test
    ]
  end
end
