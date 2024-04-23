defmodule Defectoscope.ReportBehaviour do
  @moduledoc false

  alias Defectoscope.Report

  @doc """
  Build a new report
  """
  @callback new(params :: map) :: Report.t()
end
