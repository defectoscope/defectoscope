defmodule Defectoscope.Builders.Common do
  @moduledoc """
  Provides common utility functions to help report builders
  """

  @doc """
  Determines the kind of error based on the reason
  """
  @spec format_kind(reason :: any()) :: atom() | String.t()
  def format_kind(nil = _reason), do: :unknown
  def format_kind(reason) when is_atom(reason), do: reason
  def format_kind(reason) when is_struct(reason), do: reason.__struct__
  def format_kind({exception, _}) when is_atom(exception), do: exception
  def format_kind(reason), do: inspect(reason)

  @doc """
  Formats a stacktrace into a list of strings
  """
  @spec format_stacktrace(stacktrace :: Exception.stacktrace()) :: list(String.t())
  def format_stacktrace(stacktrace) do
    stacktrace
    |> Exception.format_stacktrace()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
  end
end
