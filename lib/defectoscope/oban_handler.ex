defmodule Defectoscope.ObanHandler do
  @moduledoc """
  Handles Oban exception events and pushes them to the `IncidentsHandler`
  """

  alias Defectoscope.IncidentsHandler

  @handler_id :defectoscope_oban_exception_handler
  @event_name [:oban, :job, :exception]

  @doc """
  Attaches the handler to Oban exception events
  """
  @spec attach() :: :ok
  def attach do
    :telemetry.attach(@handler_id, @event_name, &__MODULE__.handle_exception_event/4, [])
  end

  @doc false
  def handle_exception_event(_, _, %{kind: kind, reason: reason, stacktrace: stacktrace}, _) do
    params = %{kind: kind, reason: reason, stacktrace: stacktrace, timestamp: DateTime.utc_now()}
    IncidentsHandler.push(%{source: :oban, params: params})
  end

  def handle_exception_event(_, _, _, _), do: :ok
end
