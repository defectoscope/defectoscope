defmodule Defectoscope.PlugReportTest do
  @moduledoc false

  use Defectoscope.ConnCase

  alias Defectoscope.{PlugReport, Report}

  test "new/1" do
    payload = %{
      password: "password",
      password_confirmation: "password",
      token: "token",
      api_key: "api_key",
      secret: "secret",
      some: "value"
    }

    report = get("/exception", payload) |> PlugReport.new()

    assert %Report{
             kind: RuntimeError,
             level: :error,
             message: "** (RuntimeError) Exception!",
             stacktrace: [_ | _],
             phoenix_params: phoenix_params,
             timestamp: _
           } = report

    assert %{
             status: 500,
             params: params,
             session: _,
             request_path: "/exception",
             req_headers: _,
             method: "GET",
             path_info: ["exception"],
             query_string: query_string
           } = phoenix_params

    assert %{
             "api_key" => "*******",
             "password" => "********",
             "password_confirmation" => "********",
             "secret" => "******",
             "some" => "value",
             "token" => "*****"
           } = params

    assert query_string ==
             "api_key=*******&password=********&password_confirmation=********&secret=******&some=value&token=*****"
  end
end
