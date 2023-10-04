defmodule RoverApp.Rover do
  use GenServer

  require Logger

  alias RoverApp.Grid

  def start_link([], [id]) do
    GenServer.start_link(__MODULE__, id, name: {:global, {:rover, id}})
  end

  def initialize(rover_id, {x, y}) do
    GenServer.call(process_name(rover_id), {:initialize, {x, y}})
  end

  def move(rover_id, direction) do
    GenServer.cast(process_name(rover_id), {:move, direction})
  end

  def unreserve(rover_id) do
    GenServer.call(process_name(rover_id), :unreserve)
  end

  @impl true
  def init(id) do
    Logger.info("Rover init!")
    {:ok, %{id: id, position: {nil, nil}}}
  end

  @impl true
  def handle_call({:initialize, {x, y}}, _from, state) do
    Logger.debug("Rover initialize request at {#{x}, #{y}}")

    case Grid.reserve_coordinate({x, y}, state.position, state.id) do
      {:ok, coordinate} ->
        msg = "Rover successfully intialize at #{inspect(coordinate)}"
        {:reply, msg, %{state | position: coordinate}}

      {:error, error_msg} ->
        Logger.warning(error_msg, label: "Rover initialization failed")
        {:reply, error_msg, state}
    end
  end

  @impl true
  def handle_call(:unreserve, _from, state) do
    Logger.debug("Rover unreserve request at pos: #{inspect(state.position)}.")
    {:reply, Grid.unreserve_coordinate(state.position, state.id), state}
  end

  @impl true
  def handle_cast({:move, direction}, state) do
    Logger.debug(
      "Rover move request in direction : #{direction} from pos: #{inspect(state.position)}"
    )

    state.position
    |> Grid.find_next_coordinates(direction)
    |> Grid.reserve_coordinate(state.position, state.id)
    |> case do
      {:ok, coordinate} ->
        Logger.info("Rover successfully moved to #{inspect(coordinate)}")
        {:noreply, %{state | position: coordinate}}

      {:error, _error_msg} ->
        Logger.warning("Rover is unable to move, still at #{inspect(state.position)}")
        {:noreply, state}
    end
  end

  def process_name(rover_id) do
    :global.whereis_name({:rover, rover_id})
  end
end
