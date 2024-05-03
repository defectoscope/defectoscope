defmodule Defectoscope.Util.Logger do
  @moduledoc false

  require Logger

  @doc """
  Wrapper around Logger.debug/1 that only logs if the debug flag is set to true
  """
  def debug(message) do
    if Application.get_env(:defectoscope, :debug) do
      Logger.debug(message)
    end
  end
end
