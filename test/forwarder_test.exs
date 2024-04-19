defmodule Defectoscope.ForwarderTest do
  @moduledoc false

  use Defectoscope.ConnCase

  alias Defectoscope.Forwarder

  describe "forward/1" do
    setup do
      Req.Test.stub(Forwarder, fn conn ->
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

      assert %{"status" => "ok"} = Forwarder.forward(errors).body
    end

    test "(raise exception)" do
      ok = get("/")
      assert catch_error(Forwarder.forward([ok]))
    end
  end
end
