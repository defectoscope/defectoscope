defmodule Defectoscope.ErrorHandlerTest do
  @moduledoc false

  use Defectoscope.ConnCase

  alias Defectoscope.ErrorHandler

  setup do
    error = get("/exception")
    {:ok, error: error}
  end

  test "client interface", %{error: error} do
    assert ErrorHandler.reset() == :ok
    assert ErrorHandler.get_state() == []
    assert ErrorHandler.push(error) == :ok
    assert ErrorHandler.get_state() == [error]
    assert ErrorHandler.reset() == :ok
    assert ErrorHandler.get_state() == []
  end
end
