defmodule Defectoscope.Util.Logger do
  @moduledoc false

  @doc """
  Wrapper around Logger.debug/1 that only logs if the debug flag is set to true
  """
  def debug(message) do
    if Application.get_env(:defectoscope, :debug) do
      require Logger
      Logger.debug(message)
    end
  end
end
