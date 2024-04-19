import Config

if Mix.env() == :test do
  config :defectoscope, :app_key, "test"
  config :defectoscope, :endpoint, "http://localhost:4000"
  config :defectoscope, :req_options, plug: {Req.Test, Defectoscope.Forwarder}
end
