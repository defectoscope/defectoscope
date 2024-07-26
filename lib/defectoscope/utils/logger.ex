defmodule Defectoscope.Util.Logger do
  @moduledoc false

  alias Defectoscope.Config

  require Logger

  @doc """
  Log a debug message if debug mode is enabled
  """
  def debug(message) do
    if Config.is_debug?(), do: Logger.debug(message)
  end
end
