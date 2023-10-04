defmodule RoverApp.Rover.Supervisor do
  use DynamicSupervisor

  require Logger

  alias RoverApp.Rover

  def start_link(init_arg),
    do: DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)

  def create_rover(rover_id), do: DynamicSupervisor.start_child(__MODULE__, {Rover, [rover_id]})

  def delete_rover(rover_id) do
    DynamicSupervisor.terminate_child(__MODULE__, Rover.process_name(rover_id))
  end

  @impl DynamicSupervisor
  def init(init_arg) do
    Logger.info("Rover Supervisor started!")
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [init_arg])
  end
end
