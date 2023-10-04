defmodule RoverApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    Logger.info("Starting Rover application..")

    children = [
      # Starts a worker by calling: RoverApp.Worker.start_link(arg)
      # {RoverApp.Worker, arg}
      {RoverApp.User.Supervisor, []},
      {RoverApp.Rover.Supervisor, []},
      {RoverApp.Simulator, []},
      {RoverApp.Grid, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RoverApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
