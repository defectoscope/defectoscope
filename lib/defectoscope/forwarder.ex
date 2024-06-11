defmodule Defectoscope.Forwarder do
  @moduledoc """
  Module to forward reports to the backend service
  """

  alias Defectoscope.{Report, Config, ErrorHandler}

  @doc """
  Forward errors to the error forwarder
  """
  @spec forward(list(ErrorHandler.error())) :: Req.Response.t()
  def forward(errors) do
    errors
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

  defp req_options() do
    Application.get_env(:defectoscope, :req_options, [])
  end
end
