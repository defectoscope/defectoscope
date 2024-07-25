defmodule Defectoscope.ErrorHandler do
  @moduledoc """
  GenServer that keeps track of errors and sends them to the forwarder
  """

  use GenServer

  import Defectoscope.Util.Logger, only: [debug: 1]

  alias Defectoscope.{TaskSupervisor, Forwarder, Config}

  defmodule State do
    @moduledoc """
    State of the error handler
    """

    @type t :: %{
            forwarder_ref: reference() | nil,
            errors: list(map()),
            pending_errors: list(map())
          }

    defstruct forwarder_ref: nil, errors: [], pending_errors: []
  end

  # Period for the scheduler to send the errors
  @scheduler_period :timer.seconds(20)

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Push an error params to the error handler
  """
  @spec push(error :: map()) :: :ok
  def push(error) do
    if Config.is_enabled?(), do: GenServer.cast(__MODULE__, {:push, error})
    :ok
  end

  @doc """
  Reset the state of the error handler
  """
  @spec reset() :: :ok
  def reset() do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Get the state of the error handler
  """
  @spec get_state() :: State.t()
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @doc false
  @impl true
  def init(_opts) do
    state = %State{}
    {:ok, state, {:continue, :start_scheduler}}
  end

  # Start scheduler
  @doc false
  @impl true
  def handle_continue(:start_scheduler, %State{} = state) do
    Process.send_after(self(), :start_forwarder, @scheduler_period)
    {:noreply, state}
  end

  @doc false
  @impl true
  def handle_call(:reset, _from, %State{} = state) do
    state = %{state | errors: []}
    {:reply, :ok, state}
  end

  @doc false
  @impl true
  def handle_call(:get_state, _from, %State{} = state) do
    {:reply, state, state}
  end

  @doc false
  @impl true
  def handle_cast({:push, error}, %State{errors: errors} = state) do
    state = %State{state | errors: [error | errors]}
    {:noreply, state}
  end

  # Forwarder is already running
  @doc false
  @impl true
  def handle_info(:start_forwarder, %State{forwarder_ref: ref} = state) when not is_nil(ref) do
    {:noreply, state}
  end

  # Nothing to forward yet
  @doc false
  @impl true
  def handle_info(:start_forwarder, %State{errors: []} = state) do
    {:noreply, state, {:continue, :start_scheduler}}
  end

  # Start forwarding
  @doc false
  @impl true
  def handle_info(:start_forwarder, %State{errors: errors} = _state) do
    task = Task.Supervisor.async_nolink(TaskSupervisor, Forwarder, :forward, [errors])
    state = %State{forwarder_ref: task.ref, errors: [], pending_errors: errors}
    {:noreply, state}
  end

  # Forwarder has failed
  @doc false
  @impl true
  def handle_info({ref, {:error, reason}}, %State{forwarder_ref: ref} = state) do
    debug("Forwarder has failed, reason: #{inspect(reason)}")
    Process.demonitor(ref, [:flush])
    state = %State{errors: state.errors ++ state.pending_errors}
    {:noreply, state, {:continue, :start_scheduler}}
  end

  # Forwarder has completed
  @doc false
  @impl true
  def handle_info({ref, _}, %State{forwarder_ref: ref} = state) do
    debug("Forwarder has been completed (#{length(state.pending_errors)} errors sent)")
    Process.demonitor(ref, [:flush])
    state = %State{errors: state.errors}
    {:noreply, state, {:continue, :start_scheduler}}
  end

  # Forwarder has failed
  @doc false
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, reason}, %State{forwarder_ref: ref} = state) do
    debug("Forwarder has failed, reason: #{inspect(reason)}")
    state = %State{errors: state.errors ++ state.pending_errors}
    {:noreply, state, {:continue, :start_scheduler}}
  end
end
