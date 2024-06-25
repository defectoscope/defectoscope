# Defectoscope

Defectoscope is an error tracking and reporting tool for Elixir applications. It allows you to capture errors in your application and send them to a specified endpoint for monitoring and analysis.

## Installation

The package can be installed by adding defectoscope to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:defectoscope, git: "https://github.com/shuma-id/defectoscope.git"}
  ]
end
```

Once added, run `mix deps.get` in your terminal to fetch the new dependency.

## Configuration

To start using Defectoscope, you need to set up the configuration with your application's API key and the endpoint where error reports will be sent. Add the following to your `config/config.exs`:

```elixir
config :defectoscope,
  app_key: "your_app_key",
  endpoint: "https://your_app_endpoint",
  debug: true,
  enabled: true
```

Replace "your_app_key" with the actual app key provided to you and "https://your_app_endpoint" with the URL of the error reporting endpoint.

The `debug` option is used to enable or disable debug logging.

The `enabled` option is used to enable or disable error reporting.

## Usage

Integrate Defectoscope in your application by adding `Defectoscope.Plug` to your router. This will capture any errors that occur during the handling of a request and report them automatically.

Here is an example of how to integrate it into a Phoenix router:

```elixir
defmodule AppWeb.Router do
  use AppWeb, :router
  use Defectoscope.Plug

  pipeline :browser do
    ...
  end

  scope "/", AppWeb do
    pipe_through :browser
    ...
  end
end
```

For non-Phoenix applications, you can add it directly to your Plug router:

```elixir
defmodule AppWeb.Router do
  use Plug.Router
  use Defectoscope.Plug

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Welcome")
  end
end
```

Now, Defectoscope will monitor your application for any errors and report them as configured.
