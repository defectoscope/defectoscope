defmodule Defectoscope.ErrorReport do
  @moduledoc false

  alias Defectoscope.ErrorHandler

  @type t :: %__MODULE__{
          status: integer,
          message: String.t(),
          phoenix_params: map,
          stacktrace: list,
          timestamp: DateTime.t()
        }

  @derive Jason.Encoder
  defstruct [:status, :message, :phoenix_params, :stacktrace, :timestamp]

  @spec new(error :: ErrorHandler.error()) :: __MODULE__.t()
  def new(error) do
    %__MODULE__{
      status: format_status(error),
      message: format_message(error),
      phoenix_params: format_phoenix_params(error),
      stacktrace: format_stacktrace(error),
      timestamp: format_timestamp(error)
    }
  end

  # Http status code
  defp format_status(%{reason: reason} = _error) do
    Plug.Exception.status(reason)
  end

  # Error message
  defp format_message(%{kind: kind, reason: reason, stack: stack} = _error) do
    Exception.format_banner(kind, reason, stack)
  end

  # Phoenix params for request
  defp format_phoenix_params(%{conn: nil} = _error), do: %{}

  defp format_phoenix_params(%{conn: conn} = _error) do
    %{
      method: conn.method,
      path_info: conn.path_info,
      request_path: conn.request_path,
      query_string: conn.query_string
    }
  end

  # Stacktrace for error
  defp format_stacktrace(%{stack: stack} = _error) do
    stack
    |> Exception.format_stacktrace()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end

  # Timestamp for error
  defp format_timestamp(%{timestamp: timestamp} = _error), do: timestamp

  defp format_timestamp(_errors) do
    DateTime.utc_now()
  end
end
