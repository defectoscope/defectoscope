defmodule Defectoscope.Util.Logger do
  @moduledoc false

  require Logger

  alias Defectoscope.Config

  @doc """
  Wrapper around Logger.debug/1 that only logs if the debug flag is set to true
  """
  def debug(message) do
    if Config.is_debug?() do
      Logger.debug(message)
    end
  end
end
