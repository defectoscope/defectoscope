defmodule Defectoscope.Application do
  @moduledoc false

  use Application

  alias Defectoscope.Config

  @doc false
  @impl true
  def start(_type, _args) do
    # Validate the configuration before starting the application
    Config.validate_config!()

    children = [
      {Task.Supervisor, name: Defectoscope.TaskSupervisor},
      Defectoscope.ErrorHandler
    ]

    Logger.add_backend(Defectoscope.LoggerBackend)

    opts = [strategy: :one_for_one, name: Defectoscope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
