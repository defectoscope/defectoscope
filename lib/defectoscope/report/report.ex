defmodule Defectoscope.Report do
  @moduledoc """
  Struct to represent a report
  """

  @type t :: %__MODULE__{
          kind: atom,
          level: atom,
          message: String.t(),
          phoenix_params: map,
          stacktrace: list,
          timestamp: DateTime.t()
        }

  @derive Jason.Encoder
  defstruct [
    :kind,
    :level,
    :message,
    :phoenix_params,
    :stacktrace,
    :timestamp
  ]

  @doc """
  Create a new report
  """
  @spec new(params :: %{builder: atom}) :: t()
  def new(%{builder: builder} = params) do
    try do
      builder.new(params)
    catch
      kind, reason ->
        %__MODULE__{
          kind: :defectoscope_error,
          level: :error,
          message: Exception.format_banner(kind, reason, __STACKTRACE__),
          phoenix_params: %{},
          stacktrace: __STACKTRACE__,
          timestamp: DateTime.utc_now()
        }
    end
  end
end
