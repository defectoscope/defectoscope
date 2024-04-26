import Config

if Mix.env() == :test || Mix.env() == :dev do
  config :defectoscope,
    app_key: "test",
    endpoint: "http://localhost:4000",
    req_options: [plug: {Req.Test, Defectoscope.Forwarder}]
end
