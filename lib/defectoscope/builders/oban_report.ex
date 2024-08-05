defmodule Defectoscope.Builders.ObanReport do
  @moduledoc """
  Oban report builder
  """

  @behaviour Defectoscope.Builders.ReportBuilder

  alias Defectoscope.Report
  alias Defectoscope.Builders.Common

  @type params :: %{
          kind: atom(),
          reason: any(),
          stacktrace: Exception.stacktrace()
        }

  @doc """
  Builds a new report based on an exception event
  """
  @impl true
  @spec build(params) :: Report.t()
  def build(%{kind: kind, reason: reason, stacktrace: stacktrace, timestamp: ts}) do
    %Report{
      kind: Common.format_kind(reason),
      message: Exception.format_banner(kind, reason, stacktrace),
      stacktrace: Common.format_stacktrace(stacktrace),
      timestamp: ts,
      scope: "oban"
    }
  end
end
