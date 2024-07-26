defmodule Defectoscope.Report do
  @moduledoc false

  @type t :: %__MODULE__{
          kind: atom(),
          level: atom(),
          message: String.t(),
          stacktrace: list(String.t()),
          timestamp: DateTime.t(),
          scope: String.t(),
          phoenix_params: map(),
          meta: map()
        }

  @type builder :: atom()
  @type params :: %{:builder => builder, optional(atom()) => any()}

  @derive Jason.Encoder
  defstruct [
    :kind,
    :level,
    :message,
    :stacktrace,
    :timestamp,
    scope: "runtime",
    phoenix_params: %{},
    meta: %{}
  ]

  @doc """
  Create a new report using a builder
  """
  @spec new(params) :: t()
  def new(%{builder: builder} = params) do
    try do
      builder.new(params)
    catch
      kind, reason ->
        %__MODULE__{
          kind: :defectoscope_error,
          level: :error,
          message: Exception.format_banner(kind, reason, __STACKTRACE__),
          stacktrace: __STACKTRACE__,
          timestamp: DateTime.utc_now()
        }
    end
  end
end
