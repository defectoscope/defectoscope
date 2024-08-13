import Config

# The environment this configuration file is executed on
config :defectoscope, current_env: config_env()

if config_env() == :test do
  config :defectoscope,
    app_key: "test",
    endpoint: "http://localhost:4000",
    req_options: [plug: {Req.Test, Defectoscope.Forwarder}]
end
