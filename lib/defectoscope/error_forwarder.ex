defmodule Defectoscope.ErrorForwarder do
  @moduledoc false

  alias Defectoscope.ErrorReport
  alias Defectoscope.ErrorHandler
  alias Defectoscope.Config

  @doc """
  Forward a list of errors to backend server
  """
  @spec forward(list(ErrorHandler.error())) :: Req.Response.t()
  def forward(errors) do
    errors
    |> Enum.map(&ErrorReport.new/1)
    |> request()
  end

  defp request(reports) do
    [
      method: :post,
      retry: :transient,
      body: reports |> Jason.encode!()
    ]
    |> Keyword.merge(Config.forwarder_request_opts())
    |> Req.request!()
  end
end
