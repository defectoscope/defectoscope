defmodule Defectoscope.ErrorHandler do
  @moduledoc false

  use GenServer

  @type error :: %{kind: atom, reason: any, stack: list, conn: Plug.Conn.t()}

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

  @impl true
  def init(_opts) do
    {:ok, _state = []}
  end

  @impl true
  def handle_cast({:push, _error}, state) do
    # TODO: Implement error handler
    {:noreply, state}
  end
end
