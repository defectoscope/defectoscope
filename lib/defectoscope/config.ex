defmodule Defectoscope.Config do
  @moduledoc """
  Configuration for Defectoscope

  ## Usage

  ```elixir
  config :defectoscope, :forwarder_request_opts, [base_url: "http://localhost", max_retries: 3]
  config :defectoscope, :error_forwarder_interval, :timer.minutes(10)
  ```

  ## Configuration options:

  - `:forwarder_request_opts` - Keyword list of options for the HTTP request
  - `:error_forwarder_interval` - The interval for the error forwarder to run is in milliseconds

  ### `forwarder_request_opts` options:

  - `:base_url` - Base URL for the error forwarder
  - `:retry_delay` - if not set, which is the default, the retry delay is determined by
      the value of `retry-delay` header on HTTP 429/503 responses. If the header is not set,
      the default delay follows a simple exponential backoff: 1s, 2s, 4s, 8s, ...
  - `:max_retries` - maximum number of retry attempts, defaults to `3`
  """

  @default_forwarder_request_opts [base_url: "http://localhost"]

  @doc """
  Return the list of options for the HTTP request
  """
  @spec forwarder_request_opts() :: keyword()
  def forwarder_request_opts(), do: forwarder_request_opts(Mix.env())

  # Test environment doesn't need to forward errors
  def forwarder_request_opts(:test) do
    Keyword.merge(
      @default_forwarder_request_opts,
      plug: {Req.Test, Defectoscope.Forwarder}
    )
  end

  def forwarder_request_opts(_) do
    Application.get_env(
      :defectoscope,
      :forwarder_request_opts,
      @default_forwarder_request_opts
    )
  end

  @doc """
  Return the interval for the forwarder to run
  By default it's every 10 minutes
  """
  @spec error_forwarder_interval() :: integer
  def error_forwarder_interval() do
    Application.get_env(
      :defectoscope,
      :error_forwarder_interval,
      :timer.minutes(10)
    )
  end
end
