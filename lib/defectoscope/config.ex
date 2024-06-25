defmodule Defectoscope.Config do
  @moduledoc false

  @doc """
  Enabled flag to enable or disable the Defectoscope
  """
  @spec is_enabled?() :: boolean()
  def is_enabled?() do
    Application.get_env(:defectoscope, :enabled, true)
  end

  @doc """
  Debug mode
  """
  @spec is_debug?() :: boolean()
  def is_debug?() do
    Application.get_env(:defectoscope, :debug, false)
  end

  @doc """
  Validate the configuration
  """
  @spec validate_config!() :: :ok
  def validate_config!() do
    is_enabled?() |> do_validate_config!()
  end

  defp do_validate_config!(true = _is_enabled) do
    with :error <- Application.fetch_env(:defectoscope, :app_key) do
      raise """
      Missing :app_key in the :defectoscope configuration. Please add it to your config.exs
      """
    end
  end

  defp do_validate_config!(false = _is_enabled), do: :ok

  @doc """
  Application key
  """
  @spec app_key() :: String.t()
  def app_key() do
    Application.get_env(:defectoscope, :app_key)
  end

  @doc """
  Endpoint to send reports to
  """
  @spec endpoint() :: String.t()
  def endpoint() do
    Application.get_env(
      :defectoscope,
      :endpoint,
      "https://api.defectoscope.dev/dev/track"
    )
  end
end
