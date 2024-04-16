defmodule Defectoscope.ErrorForwarderTest do
  @moduledoc false

  use Defectoscope.ConnCase

  alias Defectoscope.ErrorForwarder

  describe "forward/1" do
    setup do
      Req.Test.stub(Defectoscope.ErrorForwarder, fn conn ->
        Req.Test.json(conn, %{status: :ok})
      end)

      :ok
    end

    test "(success)" do
      errors = [
        get("/exception"),
        get("/badarith"),
        get("/bad_request"),
        get("/exit"),
        get("/throw")
      ]

      assert %{"status" => "ok"} = ErrorForwarder.forward(errors).body
    end

    test "(raise exception)" do
      ok = get("/")
      assert catch_error(ErrorForwarder.forward([ok]))
    end
  end
end
