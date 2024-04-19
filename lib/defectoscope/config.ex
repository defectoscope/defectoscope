defmodule Defectoscope.Config do
  @moduledoc false

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
