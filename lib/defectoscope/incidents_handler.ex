defmodule Defectoscope.IncidentsHandler do
  @moduledoc """
  GenServer that handles incidents and forwards them to the forwarder
  """

  use GenServer

  import Defectoscope.Utils.LoggerWrapper, only: [debug: 1]

  alias Defectoscope.{TaskSupervisor, Forwarder, Config}

  defmodule State do
    @moduledoc false

    @type t :: %{
            forwarder_ref: reference() | nil,
            incidents: list(map()),
            pending_incidents: list(map()),
            forwarder_errors: list()
          }

    defstruct forwarder_ref: nil,
              incidents: [],
              pending_incidents: [],
              forwarder_errors: []
  end

  # The interval at which the scheduler executes
  @scheduler_interval :timer.seconds(20)

  # The number of incidents to be sent in one batch
  @incidents_batch_size 100

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Push an incident to the incidents handler
  """
  @spec push(incident :: %{source: atom(), params: map()}) :: :ok
  def push(incident) do
    if Config.enabled?(), do: GenServer.cast(__MODULE__, {:push, incident}), else: :ok
  end

  @doc """
  Reset the incidents handler by clearing all stored incidents
  """
  @spec reset :: :ok
  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Get the current state of the incidents handler
  """
  @spec get_state() :: State.t()
  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  @doc """
  Retrieves the last 10 errors that occurred while the forwarder was running
  """
  @spec get_forwarder_errors() :: list()
  def get_forwarder_errors do
    GenServer.call(__MODULE__, :get_forwarder_errors)
  end

  @doc false
  @impl true
  def init(_options) do
    initial_state = %State{}
    {:ok, initial_state, {:continue, :start_scheduler}}
  end

  # Start scheduler
  @doc false
  @impl true
  def handle_continue(:start_scheduler, %State{} = state) do
    Process.send_after(self(), :start_forwarder, @scheduler_interval)
    {:noreply, state}
  end

  @doc false
  @impl true
  def handle_call(:reset, _from, %State{} = state) do
    state = %State{state | incidents: []}
    {:reply, :ok, state}
  end

  @doc false
  @impl true
  def handle_call(:get_state, _from, %State{} = state) do
    {:reply, state, state}
  end

  @doc false
  @impl true
  def handle_call(:get_forwarder_errors, _from, %State{forwarder_errors: errors} = state) do
    {:reply, errors, state}
  end

  @doc false
  @impl true
  def handle_cast({:push, incident}, %State{incidents: incidents} = state) do
    state = %State{state | incidents: incidents ++ [incident]}
    {:noreply, state}
  end

  # Forwarder task is already in progress
  @doc false
  @impl true
  def handle_info(:start_forwarder, %State{forwarder_ref: ref} = state) when not is_nil(ref) do
    {:noreply, state}
  end

  # Nothing to forward yet
  @doc false
  @impl true
  def handle_info(:start_forwarder, %State{incidents: []} = state) do
    {:noreply, state, {:continue, :start_scheduler}}
  end

  # Start forwarding task
  @doc false
  @impl true
  def handle_info(:start_forwarder, %State{incidents: incidents} = state) do
    {incidents_to_forward, remaining_incidents} = Enum.split(incidents, @incidents_batch_size)

    forwarder_task =
      Task.Supervisor.async_nolink(TaskSupervisor, Forwarder, :forward, [incidents_to_forward])

    new_state = %State{
      forwarder_ref: forwarder_task.ref,
      incidents: remaining_incidents,
      pending_incidents: incidents_to_forward,
      forwarder_errors: state.forwarder_errors
    }

    {:noreply, new_state}
  end

  # Forwarder task has failed
  @doc false
  @impl true
  def handle_info({ref, {:error, reason}}, %State{forwarder_ref: ref} = state) do
    debug("Forwarder task has failed, reason: #{inspect(reason)}")
    Process.demonitor(ref, [:flush])

    new_state = %State{
      incidents: state.incidents ++ state.pending_incidents,
      forwarder_errors: push_forwarder_error(state.forwarder_errors, reason)
    }

    {:noreply, new_state, {:continue, :start_scheduler}}
  end

  # Forwarder task has been completed
  @doc false
  @impl true
  def handle_info({ref, _}, %State{forwarder_ref: ref} = state) do
    number_of_incidents_sent = length(state.pending_incidents)
    debug("Forwarder task has been completed, #{number_of_incidents_sent} incidents sent")

    Process.demonitor(ref, [:flush])

    new_state = %State{
      incidents: state.incidents,
      forwarder_errors: state.forwarder_errors
    }

    {:noreply, new_state, {:continue, :start_scheduler}}
  end

  # Forwarder task has failed
  @doc false
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, reason}, %State{forwarder_ref: ref} = state) do
    debug("Forwarder task has failed, reason: #{inspect(reason)}")

    new_state = %State{
      incidents: state.incidents ++ state.pending_incidents,
      forwarder_errors: push_forwarder_error(state.forwarder_errors, reason)
    }

    {:noreply, new_state, {:continue, :start_scheduler}}
  end

  # Pushes an error to the list of forwarder errors and keeps only the last 10 errors
  defp push_forwarder_error(forwarder_errors, error) do
    [error | forwarder_errors] |> Enum.take(10)
  end
end
