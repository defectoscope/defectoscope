defmodule Defectoscope.Util.SensitiveDataFilter do
  @moduledoc """
  A module to filter sensitive data
  """

  # List of sensitive params
  @sensitive_params ~w(password password_confirmation token api_key secret)

  # List of sensitive headers
  @sensitive_headers ~w(authorization)

  @doc """
  Filter sensitive data from phoenix params
  """
  @spec filter_phoenix_params(map) :: map
  def filter_phoenix_params(params) do
    Enum.reduce(params, %{}, fn {key, value}, acc ->
      Map.put(acc, key, do_filter_param(key, value))
    end)
  end

  @doc """
  Filter sensitive data from query string
  """
  @spec filter_query_string(String.t()) :: String.t()
  def filter_query_string(query_string) do
    query_string
    |> Plug.Conn.Query.decode()
    |> Map.new(fn {key, value} -> {key, do_filter_param(key, value)} end)
    |> Plug.Conn.Query.encode()
    |> URI.decode()
  end

  # Filter sensitive data from a key-value pair
  defp do_filter_param(key, value) when key in @sensitive_params do
    hidden_value(value)
  end

  defp do_filter_param(_key, value), do: value

  @doc """
  Filter sensitive data from headers
  """
  @spec filter_headers(map) :: map
  def filter_headers(headers) do
    Enum.reduce(headers, %{}, fn {key, value}, acc ->
      Map.put(acc, key, do_filter_header(String.downcase(key), value))
    end)
  end

  # Filter sensitive data from a header
  defp do_filter_header(key, value) when key in @sensitive_headers do
    hidden_value(value)
  end

  defp do_filter_header(_key, value), do: value

  # Hide the value of a sensitive parameter
  defp hidden_value(value) when is_binary(value) do
    String.replace(value, ~r/./, "*")
  end

  defp hidden_value(value) when is_list(value) do
    Enum.map(value, &hidden_value/1)
  end
end
