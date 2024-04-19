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
      json: %{errors: reports}
    ]
    |> Keyword.merge(Config.forwarder_request_opts())
    |> Req.request!()
  end
end
