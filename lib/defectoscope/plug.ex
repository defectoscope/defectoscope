defmodule Defectoscope.Plug do
  @moduledoc """
  A plug to catch errors and send them to the error handler
  """

  alias Defectoscope.ErrorHandler
  alias Plug.Conn.WrapperError

  @doc false
  defmacro __using__(_opts) do
    quote do
      use Plug.ErrorHandler

      # Override the `Plug.ErrorHandler.call/2`
      def call(conn, opts) do
        try do
          super(conn, opts)
        catch
          kind, reason ->
            stack = __STACKTRACE__
            Defectoscope.Plug.handle_error(kind, reason, stack, conn)
            :erlang.raise(kind, reason, stack)
        end
      end

      defoverridable call: 2
    end
  end

  @doc false
  def handle_error(:error, %WrapperError{} = wrapped_error, _stack, _conn) do
    %{conn: conn, reason: wrapped_reason, stack: stack} = wrapped_error
    handle_error(:error, wrapped_reason, stack, conn)
  end

  @doc false
  def handle_error(_kind, %{plug_status: status}, _stack, _conn) when status < 500 do
    # TODO: Do something with this error
  end

  @doc false
  def handle_error(kind, reason, stack, conn) do
    %{kind: kind, reason: reason, stack: stack, conn: conn}
    |> ErrorHandler.push()
  end
end
