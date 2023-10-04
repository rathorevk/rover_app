defmodule RoverApp.User.Supervisor do
  use DynamicSupervisor

  require Logger

  alias RoverApp.User

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def create_user(name), do: DynamicSupervisor.start_child(__MODULE__, {User, [name]})

  def delete_user(name) do
    DynamicSupervisor.terminate_child(__MODULE__, User.process_name(name))
  end

  @impl DynamicSupervisor
  def init(init_arg) do
    Logger.info("User Supervisor started!")
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [init_arg])
  end
end
