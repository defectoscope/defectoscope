defmodule Defectoscope.IncidentsHandlerTest do
  @moduledoc false

  use Defectoscope.ConnCase, async: true

  alias Defectoscope.IncidentsHandler
  alias Defectoscope.IncidentsHandler.State

  test "client interface" do
    incident = get("/exception")
    state = %State{}

    assert IncidentsHandler.reset() == :ok
    assert IncidentsHandler.get_state() == state
    assert IncidentsHandler.push(incident) == :ok
    assert IncidentsHandler.get_state() == %{state | incidents: [incident]}
    assert IncidentsHandler.reset() == :ok
    assert IncidentsHandler.get_state() == state
  end
end
