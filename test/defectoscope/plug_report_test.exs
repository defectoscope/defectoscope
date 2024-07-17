defmodule Defectoscope.PlugReportTest do
  @moduledoc false

  use Defectoscope.ConnCase, async: true

  alias Defectoscope.{Report, PlugReportBuilder}

  test "new/1" do
    payload = %{
      password: "password",
      password_confirmation: "password",
      token: "token",
      api_key: "api_key",
      secret: ["secret1", "secret2"],
      some: "value"
    }

    report = get("/exception", payload) |> PlugReportBuilder.new()

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
             req_headers: req_headers,
             method: "GET",
             path_info: ["exception"],
             query_string: query_string
           } = phoenix_params

    assert %{
             "api_key" => "*******",
             "password" => "********",
             "password_confirmation" => "********",
             "secret" => ["*******", "*******"],
             "some" => "value",
             "token" => "*****"
           } = params

    assert query_string ==
             """
             api_key=*******
             &password=********
             &password_confirmation=********
             &secret[]=*******
             &secret[]=*******
             &some=value
             &token=*****
             """
             |> String.replace(~r/\s+/, "")

    assert %{
             "authorization" => "******",
             "referer" => "http://example.com"
           } = req_headers
  end
end
