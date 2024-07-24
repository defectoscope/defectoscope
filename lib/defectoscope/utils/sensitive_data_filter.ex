defmodule Defectoscope.Util.SensitiveDataFilter do
  @moduledoc """
  Filter sensitive data from params and headers
  """

  # Sensitive parameters that should be kept private
  @sensitive_params ~w(password password_confirmation token api_key secret)

  # Sensitive headers that should be kept private
  @sensitive_headers ~w(authorization)

  @doc """
  Filter sensitive data from phoenix params
  """
  @spec filter_phoenix_params(params :: map()) :: map()
  def filter_phoenix_params(params) do
    Enum.reduce(params, %{}, fn {key, value}, acc ->
      Map.put(acc, key, filter_param(key, value))
    end)
  end

  @doc """
  Filter sensitive data from query string
  """
  @spec filter_query_string(query_string :: String.t()) :: String.t()
  def filter_query_string(query_string) do
    query_string
    |> Plug.Conn.Query.decode()
    |> Map.new(fn {key, value} -> {key, filter_param(key, value)} end)
    |> Plug.Conn.Query.encode()
    |> URI.decode()
  end

  # Filter sensitive data from a key-value pair
  defp filter_param(key, value) when key in @sensitive_params do
    hide_value(value)
  end

  defp filter_param(_key, value), do: value

  @doc """
  Filter sensitive data from headers
  """
  @spec filter_headers(headers :: map()) :: map()
  def filter_headers(headers) do
    Enum.reduce(headers, %{}, fn {key, value}, acc ->
      Map.put(acc, key, filter_header(String.downcase(key), value))
    end)
  end

  # Filter sensitive data from a header
  defp filter_header(key, value) when key in @sensitive_headers do
    hide_value(value)
  end

  defp filter_header(_key, value), do: value

  # Hide sensitive data from a value
  defp hide_value(value) when is_binary(value) do
    value
    |> String.slice(0, 10)
    |> String.replace(~r/./, "*")
  end

  defp hide_value(values) when is_list(values) do
    Enum.map(values, &hide_value/1)
  end
end
