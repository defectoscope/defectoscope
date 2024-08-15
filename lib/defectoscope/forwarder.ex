defmodule Defectoscope.Forwarder do
  @moduledoc """
  Forwards incidents to the backend server
  """

  alias Defectoscope.{Report, Config}

  @doc """
  Forwards a list of incidents to the backend server
  """
  @spec forward(incidents :: list(map())) :: {:ok, Req.Response.t()} | {:error, Exception.t()}
  def forward(incidents) do
    reports = Enum.map(incidents, &Report.new/1)
    make_request(reports)
  end

  defp make_request(reports) do
    req_options = [
      method: :post,
      retry: :transient,
      base_url: Config.endpoint_url(),
      retry_log_level: retry_log_level(),
      max_retries: 60,
      json: json_body(reports)
    ]

    req_options
    |> Keyword.merge(Config.req_options())
    |> Req.request()
  end

  defp json_body(reports) do
    %{app_key: Config.app_key(), env: Config.env(), reports: reports}
  end

  defp retry_log_level do
    if Config.debug_mode_enabled?(), do: :error, else: false
  end
end
