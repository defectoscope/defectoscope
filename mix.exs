defmodule Defectoscope.MixProject do
  @moduledoc false

  use Mix.Project

  @source_url "https://github.com/defectoscope/defectoscope"
  @version "0.1.0"

  def project do
    [
      app: :defectoscope,
      version: @version,
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),
      versioning: versioning(),
      name: "Defectoscope",
      package: package(),
      source_url: @source_url,
      description: description(),
      docs: docs()
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
      {:req, "~> 0.5"},
      {:excoveralls, "~> 0.18", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test]},
      {:lexical_credo, "~> 0.1.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.cobertura": :test
    ]
  end

  defp package do
    [
      name: "Defectoscope",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["AGPL-3.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Configures versioning
  defp versioning, do: [commit_msg: "Version %s"]

  defp description,
    do: "Simple error tracking and app monitoring for Elixir developers"

  defp docs do
    [
      source_url: @source_url,
      source_ref: "v#{@version}",
      main: "readme",
      formatters: ["html"],
      extras: ["README.md", "LICENSE"]
    ]
  end
end
