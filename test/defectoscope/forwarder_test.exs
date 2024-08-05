defmodule Defectoscope.ForwarderTest do
  @moduledoc false

  use Defectoscope.ConnCase, async: true

  alias Defectoscope.Forwarder

  describe "forward/1" do
    setup do
      Req.Test.stub(Forwarder, fn conn ->
        Req.Test.json(conn, %{status: :ok})
      end)

      :ok
    end

    test "(plug: success)" do
      incidents =
        [
          get("/exception"),
          get("/badarith"),
          get("/bad_request"),
          get("/exit"),
          get("/throw")
        ]
        |> Enum.map(&%{source: :plug, params: &1})

      assert {:ok, _response} = Forwarder.forward(incidents)
    end

    test "(plug: raise exception)" do
      ok = get("/")
      assert catch_error(Forwarder.forward([ok]))
    end

    test "(logger backend: success)" do
      incident = %{
        source: :logger,
        params: %{
          level: :error,
          message: ["** (ArithmeticError) bad argument in arithmetic expression"],
          meta: %{
            crash_reason:
              {%ArithmeticError{
                 message: "bad argument in arithmetic expression"
               }, [{:erlang, :/, [1, 0], [error_info: %{module: :erl_erts_errors}]}]},
            erl_level: :error
          },
          metadata: [user_params: [1, 0]],
          timestamp: ~U[2024-04-23 08:56:19.327874Z]
        }
      }

      assert {:ok, _response} = Forwarder.forward([incident])
    end

    test "(oban: success)" do
      incident = %{
        source: :oban,
        params: %{
          kind: :error,
          reason: "bad argument in arithmetic expression",
          stacktrace: [{:erlang, :/, [1, 0], [error_info: %{module: :erl_erts_errors}]}],
          timestamp: ~U[2024-04-23 08:56:19.327874Z]
        }
      }

      assert {:ok, _response} = Forwarder.forward([incident])
    end
  end
end
