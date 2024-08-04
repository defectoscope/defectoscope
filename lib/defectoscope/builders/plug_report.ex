defmodule Defectoscope.Builders.PlugReport do
  @moduledoc """
  Plug report builder
  """

  @behaviour Defectoscope.Builders.ReportBuilder

  alias Defectoscope.Report
  alias Defectoscope.Builders.Common
  alias Defectoscope.Utils.SensitiveDataFilter

  @type params :: %{
          kind: atom(),
          reason: any(),
          stacktrace: Exception.stacktrace(),
          conn: Plug.Conn.t() | nil,
          timestamp: DateTime.t()
        }

  @doc """
  Builds a report from a plug error
  """
  @impl true
  @spec build(params) :: Report.t()
  def build(%{kind: kind, reason: reason, stacktrace: stacktrace, conn: conn, timestamp: ts}) do
    %Report{
      kind: Common.format_kind(reason),
      message: Exception.format_banner(kind, reason, stacktrace),
      stacktrace: Common.format_stacktrace(stacktrace),
      phoenix_params: get_phoenix_params(conn, reason),
      timestamp: ts,
      scope: "web"
    }
  end

  # Extracts Phoenix-specific parameters from the connection
  defp get_phoenix_params(nil = _conn, _reason), do: %{}

  defp get_phoenix_params(conn, reason) do
    %{
      status: Plug.Exception.status(reason),
      method: conn.method,
      path_info: conn.path_info,
      request_path: conn.request_path,
      query_string: filter_query_string(conn.query_string),
      params: filter_conn_params(conn.params),
      req_headers: filter_headers(conn.req_headers),
      session: get_session(conn.private)
    }
  end

  # Filters connection parameters to remove sensitive data.
  defp filter_conn_params(%Plug.Conn.Unfetched{} = _params), do: %{}

  defp filter_conn_params(params) do
    SensitiveDataFilter.filter_phoenix_params(params)
  end

  # Filters request headers to remove sensitive data
  defp filter_headers(headers) do
    headers = Map.new(headers)
    SensitiveDataFilter.filter_headers(headers)
  end

  # Filters query string to remove sensitive data
  defp filter_query_string(query_string) do
    SensitiveDataFilter.filter_query_string(query_string)
  end

  # Retrieves the session data from the connection's private data
  defp get_session(%{plug_session: session} = _private), do: session
  defp get_session(_private), do: %{}
end
