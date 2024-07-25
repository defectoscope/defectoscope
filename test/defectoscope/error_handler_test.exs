defmodule Defectoscope.ErrorHandlerTest do
  @moduledoc false

  use Defectoscope.ConnCase, async: true

  alias Defectoscope.ErrorHandler
  alias Defectoscope.ErrorHandler.State

  test "client interface" do
    error = get("/exception")
    state = %State{}

    assert ErrorHandler.reset() == :ok
    assert ErrorHandler.get_state() == state
    assert ErrorHandler.push(error) == :ok
    assert ErrorHandler.get_state() == %{state | errors: [error]}
    assert ErrorHandler.reset() == :ok
    assert ErrorHandler.get_state() == state
  end
end
