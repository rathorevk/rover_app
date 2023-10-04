defmodule RoverApp.User do
  use GenServer

  require Logger

  alias RoverApp.Rover
  alias RoverApp.Rover.Supervisor

  def start_link([], [name]) do
    GenServer.start_link(__MODULE__, name, name: {:global, {:user, name}})
  end

  def process_name(user_name) do
    :global.whereis_name({:user, user_name})
  end

  def init_rover(user_name, rover_id, {x, y} \\ {0, 0}) do
    GenServer.call(process_name(user_name), {:init_rover, rover_id, {x, y}})
  end

  def move_rover_up(user_name, rover_id) do
    GenServer.call(process_name(user_name), {:move_rover, {:up, rover_id}})
  end

  def move_rover_down(user_name, rover_id) do
    GenServer.call(process_name(user_name), {:move_rover, {:down, rover_id}})
  end

  def move_rover_left(user_name, rover_id) do
    GenServer.call(process_name(user_name), {:move_rover, {:left, rover_id}})
  end

  def move_rover_right(user_name, rover_id) do
    GenServer.call(process_name(user_name), {:move_rover, {:right, rover_id}})
  end

  @impl true
  def init(name) do
    Logger.info("User with name: #{name} created successfully")
    {:ok, %{name: name}}
  end

  @impl true
  def handle_call({:init_rover, rover_id, {x, y}}, _from, state) do
    case Supervisor.create_rover(rover_id) do
      {:ok, _pid} ->
        Logger.info("Rover #{rover_id} initialized successfully!")
        {:reply, Rover.initialize(rover_id, {x, y}), state}

      {:error, error} ->
        Logger.warning("Rover #{rover_id} couldn't initialize error: #{inspect(error)}")
        {:reply, :init_rover_error, state}
    end
  end

  @impl true
  def handle_call({:move_rover, {direction, rover_id}}, _from, state) do
    {:reply, Rover.move(rover_id, direction), state}
  end
end
