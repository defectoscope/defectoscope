defmodule Defectoscope.LoggerBackend do
  @moduledoc false

  @behaviour :gen_event

  alias Defectoscope.ErrorHandler

  def init(__MODULE__) do
    {:ok, []}
  end

  def handle_event({level, _gl, {Logger, message, _timestamp, metadata}}, opts) do
    ErrorHandler.push(%{
      kind: :logger,
      level: level,
      reason: IO.chardata_to_string(message),
      stack: stacktrace(metadata),
      conn: nil,
      timestamp: DateTime.utc_now()
    })

    {:ok, opts}
  end

  def handle_event(_event, opts) do
    {:ok, opts}
  end

  def handle_call(_messsage, opts) do
    {:ok, nil, opts}
  end

  # Create a stacktrace from the metadata
  defp stacktrace(metadata) do
    metadata = Enum.into(metadata, %{})
    [Tuple.append(metadata.mfa, file: metadata.file, line: metadata.line)]
  end
end
