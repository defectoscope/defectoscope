defmodule Defectoscope.Utils.LoggerWrapper do
  @moduledoc """
  Wrapper around the Logger module
  """

  alias Defectoscope.Config

  require Logger

  @doc """
  Logs a debug message if debug mode is enabled.
  """
  @spec debug(message :: String.t()) :: :ok
  def debug(message) do
    if Config.debug_mode_enabled?(), do: Logger.debug(message), else: :ok
  end
end
