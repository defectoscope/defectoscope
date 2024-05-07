defmodule Defectoscope.Config do
  @moduledoc false

  @doc """
  Check if the defectoscope is enabled
  By default it is enabled
  """
  @spec is_enabled?() :: boolean
  def is_enabled?() do
    Application.get_env(:defectoscope, :enabled, true)
  end

  @doc """
  Check if the debug mode is enabled
  By default it is disabled
  """
  @spec is_debug?() :: boolean
  def is_debug?() do
    Application.get_env(:defectoscope, :debug, false)
  end

  @doc """
  Validate the configuration
  """
  def validate_config!() do
    for key <- [:app_key, :endpoint] do
      with :error <- Application.fetch_env(:defectoscope, key) do
        raise """
        Missing :#{key} in the :defectoscope configuration. Please add it to your config.exs
        """
      end
    end
  end

  @doc """
  Application key
  """
  @spec app_key() :: String.t()
  def app_key() do
    Application.get_env(:defectoscope, :app_key)
  end

  @doc """
  Endpoint to send the reports to
  """
  @spec endpoint() :: String.t()
  def endpoint() do
    Application.get_env(:defectoscope, :endpoint)
  end
end
