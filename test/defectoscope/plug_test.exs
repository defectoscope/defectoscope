defmodule Defectoscope.PlugTest do
  @moduledoc false

  use Defectoscope.ConnCase, async: true

  test "GET / (success)" do
    %{conn: conn} = get("/")
    # Check that the `call` from the defectoscope plug has been overridden by the router
    assert %Plug.Conn{assigns: %{overridden?: true}} = conn
    assert %{status: 200, state: :sent, resp_body: "OK"} = conn
  end

  test "GET /exception (raise exception)" do
    %{conn: conn, reason: reason} = get("/exception")
    assert %RuntimeError{message: "Exception!"} = reason
    # Since we have `conn` before the exception is raised, it's state should be unset
    assert conn.state == :unset
  end
end
