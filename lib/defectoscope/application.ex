defmodule Defectoscope.Application do
  @moduledoc false

  use Application

  @doc false
  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Defectoscope.TaskSupervisor},
      Defectoscope.ErrorHandler
    ]

    opts = [strategy: :one_for_one, name: Defectoscope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
