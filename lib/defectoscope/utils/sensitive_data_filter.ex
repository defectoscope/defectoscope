defmodule Defectoscope.Util.SensitiveDataFilter do
  @moduledoc """
  A module to filter sensitive data from phoenix params
  """

  @sensitive_keys ~w(password password_confirmation token api_key secret)

  @doc """
  Filter sensitive data from phoenix params
  """
  @spec filter_phoenix_params(map) :: map
  def filter_phoenix_params(params) do
    Enum.reduce(params, %{}, fn {key, value}, acc ->
      Map.put(acc, key, do_filter(key, value))
    end)
  end

  @doc """
  Filter sensitive data from query string
  """
  @spec filter_query_string(String.t()) :: String.t()
  def filter_query_string(query_string) do
    query_string
    |> URI.query_decoder()
    |> Map.new(fn {key, value} -> {key, do_filter(key, value)} end)
    |> URI.encode_query()
    |> URI.decode()
  end

  # If the key is in the list of sensitive keys, replace the value with "*"
  defp do_filter(key, value) when key in @sensitive_keys do
    String.replace(value, ~r/./, "*")
  end

  defp do_filter(_key, value), do: value
end
