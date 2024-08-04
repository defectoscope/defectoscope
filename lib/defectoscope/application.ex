defmodule Defectoscope.Application do
  @moduledoc false

  use Application

  alias Defectoscope.{Config, LoggerBackend, ObanHandler}

  @doc false
  @impl true
  def start(_type, _args) do
    # Validate config before starting the application
    Config.validate_config!()

    # Add the logger backend to handle Logger events
    Logger.add_backend(LoggerBackend)

    # Attach the oban error handler to Oban events
    ObanHandler.attach()

    children = [
      {Task.Supervisor, name: Defectoscope.TaskSupervisor},
      Defectoscope.IncidentsHandler
    ]

    opts = [strategy: :one_for_one, name: Defectoscope.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
