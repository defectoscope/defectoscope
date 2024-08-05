defmodule Defectoscope.Builders.ReportBuilder do
  @moduledoc """
  Defines the behaviour for building reports
  """

  alias Defectoscope.Builders.{
    Report,
    PlugReport,
    ObanReport,
    LoggerReport
  }

  @doc """
  Build a new report
  """
  @callback build(params :: map()) :: Report.t()

  @doc """
  Build a new report from a report builder
  """
  @spec build!(source :: atom(), params :: map()) :: Report.t()
  def build!(source, params) do
    case source do
      :plug -> PlugReport.build(params)
      :oban -> ObanReport.build(params)
      :logger -> LoggerReport.build(params)
      _ -> raise "Unknown incident source: #{source}"
    end
  end
end
