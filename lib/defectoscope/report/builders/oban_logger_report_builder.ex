defmodule Defectoscope.ObanLoggerReportBuilder do
  @moduledoc """
  Oban logger report builder
  """

  @behaviour Defectoscope.ReportBuilderBehaviour

  alias Defectoscope.Report

  @type params :: %{
          kind: atom(),
          reason: any(),
          stacktrace: list()
        }

  @impl true
  @spec new(params) :: Report.t()
  def new(%{kind: kind, reason: reason, stacktrace: stacktrace, timestamp: timestamp} = _params) do
    %Report{
      kind: kind,
      level: :error,
      message: Exception.format_banner(kind, reason, stacktrace),
      stacktrace: format_stacktrace(stacktrace),
      timestamp: timestamp
    }
  end

  defp format_stacktrace(stacktrace) do
    stacktrace
    |> Exception.format_stacktrace()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end
end
