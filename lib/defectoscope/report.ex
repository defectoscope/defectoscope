defmodule Defectoscope.Report do
  @moduledoc """
  Defines a report struct
  """

  alias Defectoscope.Builders.{ReportBuilder, Common}

  @type t :: %__MODULE__{
          kind: atom(),
          message: String.t(),
          stacktrace: list(String.t()),
          timestamp: DateTime.t(),
          level: atom(),
          scope: String.t(),
          phoenix_params: map(),
          meta: map()
        }

  @derive Jason.Encoder
  defstruct [
    :kind,
    :message,
    :stacktrace,
    :timestamp,
    level: :error,
    scope: "runtime",
    phoenix_params: %{},
    meta: %{}
  ]

  @doc """
  Creates a new report using a report builder
  """
  @spec new(incident :: %{source: atom(), params: map()}) :: t()
  def new(%{source: source, params: params}) do
    try do
      ReportBuilder.build!(source, params)
    catch
      kind, reason -> new(kind, reason, __STACKTRACE__) |> Map.put(:kind, :defectoscope_error)
    end
  end

  @doc """
  Creates a new report with the specified kind, message, and stack trace
  """
  @spec new(kind :: atom(), reason :: any(), stacktrace :: Exception.stacktrace()) :: t()
  def new(kind, reason, stacktrace) do
    %__MODULE__{
      kind: Common.format_kind(reason),
      level: :error,
      message: Exception.format_banner(kind, reason, stacktrace),
      stacktrace: Common.format_stacktrace(stacktrace),
      timestamp: DateTime.utc_now()
    }
  end
end
