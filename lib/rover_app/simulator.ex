defmodule RoverApp.Simulator do
  use GenServer

  require Logger

  alias RoverApp.Rover
  alias RoverApp.Rover.Supervisor, as: RoverSupervisor
  alias RoverApp.User.Supervisor, as: UserSupervisor

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def create_user(user_name) do
    GenServer.cast(__MODULE__, {:create_user, user_name})
  end

  def init_rover(rover_id, {x, y} \\ {0, 0}) do
    GenServer.cast(__MODULE__, {:init_rover, rover_id, {x, y}})
  end

  def stop_rover(rover_id) do
    GenServer.cast(__MODULE__, {:stop_rover, rover_id})
  end

  def move_rover_up(rover_id) do
    GenServer.cast(__MODULE__, {:move_rover, {:up, rover_id}})
  end

  def move_rover_down(rover_id) do
    GenServer.cast(__MODULE__, {:move_rover, {:down, rover_id}})
  end

  def move_rover_left(rover_id) do
    GenServer.cast(__MODULE__, {:move_rover, {:left, rover_id}})
  end

  def move_rover_right(rover_id) do
    GenServer.cast(__MODULE__, {:move_rover, {:right, rover_id}})
  end

  @impl true
  def init(:ok) do
    Logger.info("Simulator started successfully!")
    {:ok, %{user: []}}
  end

  @impl true
  def handle_cast({:create_user, user_name}, state) do
    case UserSupervisor.create_user(user_name) do
      {:ok, _pid} ->
        Logger.info("User created successfully!")
        {:noreply, %{state | user: state.user ++ user_name}}

      {:error, error} ->
        Logger.warning(error, label: "User couldn't created, error: ")
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:init_rover, rover_id, {x, y}}, state) do
    case RoverSupervisor.create_rover(rover_id) do
      {:ok, _pid} ->
        Logger.info("Rover #{rover_id} created successfully!")
        Rover.initialize(rover_id, {x, y})
        {:noreply, state}

      {:error, error} ->
        Logger.warning("Rover #{rover_id} couldn't initialize error: #{inspect(error)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:stop_rover, rover_id}, state) do
    case Rover.unreserve(rover_id) do
      {:ok, _msg} ->
        Logger.info("Rover #{rover_id} stopped successfully!")
        {:noreply, state}

      {:error, error} ->
        Logger.warning("Rover #{rover_id} couldn't stopped error: #{inspect(error)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:move_rover, {direction, rover_id}}, state) do
    Rover.move(rover_id, direction)
    {:noreply, state}
  end
end
