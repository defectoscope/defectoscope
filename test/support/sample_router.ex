defmodule Defectoscope.SampleRouter do
  @moduledoc """
  Sample router for testing
  """

  use Plug.Router
  use Defectoscope.Plug

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "OK")
  end

  get "/exception" do
    raise "Exception!"
    send_resp(conn, 200, "Exception!")
  end

  get "/badarith" do
    _ = 1 / String.to_integer("0")
    send_resp(conn, 200, "Badarith!")
  end

  get "/bad_request" do
    raise %Plug.BadRequestError{}
    send_resp(conn, 200, "Bad request!")
  end

  get "/exit" do
    exit(:exited)
    send_resp(conn, 200, "Exit!")
  end

  get "/throw" do
    throw(:thrown)
    send_resp(conn, 200, "Throw!")
  end

  def call(conn, opts) do
    conn
    |> Plug.Conn.assign(:overridden?, true)
    |> super(opts)
  end
end
