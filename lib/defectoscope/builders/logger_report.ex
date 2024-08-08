defmodule Defectoscope.Builders.LoggerReport do
  @moduledoc """
  Logger report builder
  """

  @behaviour Defectoscope.Builders.ReportBuilder

  alias Defectoscope.Report
  alias Defectoscope.Builders.Common

  @type params :: %{
          level: atom(),
          message: String.t(),
          meta: map(),
          metadata: Keyword.t(),
          timestamp: DateTime.t()
        }

  @doc """
  Builds a new report from a log event
  """
  @impl true
  @spec build(params) :: Report.t()
  def build(%{level: level, message: message, meta: meta, metadata: metadata, timestamp: ts}) do
    reason = extract_reason(meta)
    stacktrace = extract_stacktrace(meta)

    %Report{
      kind: Common.format_kind(reason),
      level: level,
      message: format_message(reason, stacktrace, message),
      stacktrace: Common.format_stacktrace(stacktrace),
      meta: format_metadata(metadata),
      timestamp: ts
    }
  end

  # Extracts the reason from the meta or returns nil
  defp extract_reason(%{crash_reason: {reason, _}}) do
    if is_exception(reason) or is_atom(reason), do: reason
  end

  defp extract_reason(_meta), do: nil

  # Extracts the stacktrace from the meta or returns an empty list
  defp extract_stacktrace(%{crash_reason: {_, stacktrace}}) when is_list(stacktrace),
    do: stacktrace

  defp extract_stacktrace(_meta), do: []

  # Formats the error message based on the reason and stacktrace or returns the logger message
  defp format_message(nil = _reason, _stacktrace, message) do
    IO.chardata_to_string(message)
  end

  defp format_message(reason, stacktrace, _message) do
    Exception.format_banner(:error, reason, stacktrace)
  end

  # Formats metadata by converting values to strings
  defp format_metadata(metadata) do
    Map.new(metadata, fn {k, v} -> {k, inspect(v)} end)
  end
end
