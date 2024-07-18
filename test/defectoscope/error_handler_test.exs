defmodule Defectoscope.ErrorHandlerTest do
  @moduledoc false

  use Defectoscope.ConnCase, async: true

  alias Defectoscope.ErrorHandler

  setup do
    error = get("/exception")

    default_state = %{
      forwarder_ref: nil,
      errors: [],
      pending_errors: []
    }

    {:ok, error: error, default_state: default_state}
  end

  test "client interface", %{error: error, default_state: default_state} do
    assert ErrorHandler.reset() == :ok
    assert ErrorHandler.get_state() == default_state
    assert ErrorHandler.push(error) == :ok
    assert ErrorHandler.get_state() == %{default_state | errors: [error]}
    assert ErrorHandler.reset() == :ok
    assert ErrorHandler.get_state() == default_state
  end
end
