defmodule Defectoscope.ConnCase do
  @moduledoc false

  @doc false
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case
      use Plug.Test

      # Make `get` requests to the sample router
      defp get(path, params \\ nil) do
        conn =
          conn(:get, path, params)
          |> put_req_header("authorization", "Bearer secret-token-key")
          |> put_req_header("referer", "http://example.com")

        try do
          %{conn: Defectoscope.SampleRouter.call(conn, [])}
        catch
          kind, reason ->
            case reason do
              %Plug.Conn.WrapperError{conn: conn, reason: reason} ->
                build_error(kind, reason, __STACKTRACE__, conn)

              _reason ->
                build_error(kind, reason, __STACKTRACE__, conn)
            end
        end
      end

      defp build_error(kind, reason, stacktrace, conn) do
        %{
          conn: conn,
          kind: kind,
          reason: reason,
          stacktrace: stacktrace,
          timestamp: DateTime.utc_now()
        }
      end
    end
  end
end
