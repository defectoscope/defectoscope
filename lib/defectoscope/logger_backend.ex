defmodule Defectoscope.LoggerBackend do
  @moduledoc """
  Handles Logger error messages and pushes them to the `IncidentsHandler`
  """

  @behaviour :gen_event

  alias Defectoscope.IncidentsHandler

  require Logger

  @log_levels ~w(error critical emergency alert)a

  @meta_keys ~w(
    application erl_level initial_call registered_name function line
    module pid time file gl domain mfa crash_reason
  )a

  @doc false
  @impl true
  def init(__MODULE__) do
    {:ok, nil}
  end

  # Ignore events from other nodes
  @doc false
  @impl true
  def handle_event({_, gl, {_, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  @doc false
  @impl true
  def handle_event({level, _, {_, message, _, meta}}, state) when level in @log_levels do
    params = %{
      level: level,
      message: message,
      meta: Map.new(meta),
      metadata: Keyword.drop(meta, @meta_keys),
      timestamp: DateTime.utc_now()
    }

    IncidentsHandler.push(%{source: :logger, params: params})

    {:ok, state}
  end

  @doc false
  @impl true
  def handle_event(_event, state) do
    {:ok, state}
  end

  @doc false
  @impl true
  def handle_call(_message, state) do
    {:reply, :ok, state}
  end
end
