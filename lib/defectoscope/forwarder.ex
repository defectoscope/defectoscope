defmodule Defectoscope.Forwarder do
  @moduledoc """
  Forward incidents to the backend server
  """

  alias Defectoscope.{Report, Config}

  @doc """
  Forward incidents to the backend server
  """
  @spec forward(incidents :: list(map())) :: Req.Response.t()
  def forward(incidents) do
    incidents
    |> Enum.map(&Report.new/1)
    |> request()
  end

  defp request(reports) do
    [
      method: :post,
      retry: :transient,
      base_url: Config.endpoint(),
      retry_log_level: if(Config.is_debug?(), do: :error, else: false),
      max_retries: 60,
      json: %{app_key: Config.app_key(), env: Mix.env(), reports: reports}
    ]
    |> Keyword.merge(req_options())
    |> Req.request()
  end

  # Req request options from the configuration
  defp req_options() do
    Application.get_env(:defectoscope, :req_options, [])
  end
end
