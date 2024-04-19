defmodule Defectoscope.ErrorHandler do
  @moduledoc """
  GenServer that keeps track of errors and sends them to the error forwarder
  """

  use GenServer

  alias Defectoscope.{TaskSupervisor, Forwarder}

  @type state :: %{
          forwarder_ref: reference | nil,
          errors: list(error),
          pending_errors: list(error)
        }

  @type error :: %{
          kind: atom,
          reason: any,
          stack: list(tuple),
          conn: Plug.Conn.t() | nil,
          timestamp: DateTime.t()
        }

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Push an error to the error handler
  """
  @spec push(error) :: :ok
  def push(error) do
    GenServer.cast(__MODULE__, {:push, error})
  end

  @doc """
  Reset the error handler
  """
  @spec reset() :: :ok
  def reset() do
    GenServer.call(__MODULE__, :reset)
  end

  @doc """
  Get the state of the error handler
  """
  @spec get_state() :: list(error)
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @impl true
  def init(_opts) do
    state = %{forwarder_ref: nil, errors: [], pending_errors: []}
    {:ok, state, {:continue, :start_scheduler}}
  end

  @impl true
  # Start the forwarder task every minute
  def handle_continue(:start_scheduler, state) do
    Process.send_after(self(), :start_forwarder, :timer.minutes(1))
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

  @impl true
  # Error forwarder is already running
  def handle_info(:start_forwarder, %{forwarder_ref: ref} = state) when not is_nil(ref) do
    {:noreply, state}
  end

  @impl true
  # Nothing to forward yet
  def handle_info(:start_forwarder, %{errors: []} = state) do
    {:noreply, state}
  end

  @impl true
  # Start error forwarding
  def handle_info(:start_forwarder, %{errors: errors} = state) do
    task = Task.Supervisor.async_nolink(TaskSupervisor, Forwarder, :forward, [errors])
    state = %{state | forwarder_ref: task.ref, errors: [], pending_errors: errors}
    {:noreply, state}
  end

  @impl true
  # Error forwarder has successfully completed
  def handle_info({ref, _}, %{forwarder_ref: ref} = state) do
    Process.demonitor(ref, [:flush])
    state = %{state | forwarder_ref: nil, pending_errors: []}
    {:noreply, state, {:continue, :start_scheduler}}
  end

  @impl true
  # Error forwarding down with an error
  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{forwarder_ref: ref} = state) do
    state = %{
      state
      | forwarder_ref: nil,
        errors: state.errors ++ state.pending_errors,
        pending_errors: []
    }

    {:noreply, state, {:continue, :start_scheduler}}
  end
end
