defmodule Defectoscope.ConnCase do
  @moduledoc false

  @doc false
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      use Plug.Test

      # Make `get` requests to the sample router
      defp get(path, params \\ nil) do
        conn = conn(:get, path, params)

        try do
          %{conn: Defectoscope.SampleRouter.call(conn, [])}
        catch
          kind, reason ->
            case reason do
              %Plug.Conn.WrapperError{conn: conn, reason: reason} ->
                %{conn: conn, kind: kind, reason: reason, stack: __STACKTRACE__}

              _ ->
                %{conn: conn, kind: kind, reason: reason, stack: __STACKTRACE__}
            end
        end
      end
    end
  end
end
