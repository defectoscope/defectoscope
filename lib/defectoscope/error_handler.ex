defmodule Defectoscope.ErrorHandler do
  @moduledoc """
  GenServer that keeps track of errors and sends them to the error forwarder
  """

  use GenServer

  import Defectoscope.Util.Logger, only: [debug: 1]

  alias Defectoscope.{TaskSupervisor, Forwarder, Config}

  @type error :: map()
  @type state :: %{
          forwarder_ref: reference() | nil,
          errors: list(error),
          pending_errors: list(error)
        }

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Push an error params to the error handler
  """
  @spec push(error) :: :ok
  def push(error) do
    if Config.is_enabled?(),
      do: GenServer.cast(__MODULE__, {:push, error}),
      else: :ok
  end

  @doc """
  Reset the error handler
  """
  @spec reset() :: :ok
  def reset() do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Get current state of the error handler
  """
  @spec get_state() :: state
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @doc false
  @impl true
  def init(_opts) do
    state = %{forwarder_ref: nil, errors: [], pending_errors: []}
    {:ok, state, {:continue, :start_scheduler}}
  end

  # Start the forwarder task every minute
  @impl true
  def handle_continue(:start_scheduler, state) do
    Process.send_after(self(), :start_forwarder, :timer.seconds(20))
    {:noreply, state}
  end

  @impl true
  def handle_call(:reset, _from, state) do
    {:reply, :ok, %{state | errors: []}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:push, error}, %{errors: errors} = state) do
    {:noreply, %{state | errors: [error | errors]}}
  end

  # Error forwarder is already running
  @impl true
  def handle_info(:start_forwarder, %{forwarder_ref: ref} = state) when not is_nil(ref) do
    {:noreply, state}
  end

  # Nothing to forward yet
  @impl true
  def handle_info(:start_forwarder, %{errors: []} = state) do
    {:noreply, state, {:continue, :start_scheduler}}
  end

  # Start error forwarding
  @impl true
  def handle_info(:start_forwarder, %{errors: errors} = state) do
    task = Task.Supervisor.async_nolink(TaskSupervisor, Forwarder, :forward, [errors])
    state = %{state | forwarder_ref: task.ref, errors: [], pending_errors: errors}
    {:noreply, state}
  end

  # Error forwarding down with an error
  @impl true
  def handle_info({ref, {:error, reason}}, %{forwarder_ref: ref} = state) do
    Process.demonitor(ref, [:flush])
    debug("Error forwarder has failed, reason: #{inspect(reason)}")

    state = %{
      state
      | forwarder_ref: nil,
        errors: state.errors ++ state.pending_errors,
        pending_errors: []
    }

    {:noreply, state, {:continue, :start_scheduler}}
  end

  # Error forwarder has successfully completed
  @impl true
  def handle_info({ref, _}, %{forwarder_ref: ref} = state) do
    Process.demonitor(ref, [:flush])

    debug("""
      Error forwarder has successfully completed,
      was sent #{length(state.pending_errors)} errors
    """)

    state = %{state | forwarder_ref: nil, pending_errors: []}
    {:noreply, state, {:continue, :start_scheduler}}
  end

  # Error forwarding down with an error
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, reason}, %{forwarder_ref: ref} = state) do
    debug("Error forwarder has failed, reason: #{inspect(reason)}")

    state = %{
      state
      | forwarder_ref: nil,
        errors: state.errors ++ state.pending_errors,
        pending_errors: []
    }

    {:noreply, state, {:continue, :start_scheduler}}
  end
end
