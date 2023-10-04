defmodule RoverApp.Grid do
  use GenServer

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def reserve_coordinate({x, y}, prev_pos, rover_id) do
    GenServer.call(__MODULE__, {:reserve_coordinate, rover_id, {x, y}, prev_pos})
  end

  def unreserve_coordinate({x, y}, rover_id) do
    GenServer.call(__MODULE__, {:unreserve_coordinate, rover_id, {x, y}})
  end

  def init(_args) do
    [x, y] = grid_size()
    grid = initialize_grid([x, y])
    Logger.info("Grid size of #{x}x#{y} initialize successfully!")
    {:ok, %{grid: grid}}
  end

  def handle_call({:reserve_coordinate, rover_id, {x, y}, prev_pos}, _from, state) do
    Logger.debug("Reserve coordinate: #{inspect({x, y})}, prev_coordinate:  #{inspect(prev_pos)}")
    {response, grid} = reserve_coordinate(rover_id, {x, y}, prev_pos, state.grid)
    {:reply, response, %{state | grid: grid}}
  end

  def handle_call({:unreserve_coordinate, rover_id, {x, y}}, _from, state) do
    Logger.debug("Unreserve coordinate: #{inspect({x, y})}.")
    {response, grid} = unreserve_coordinate({x, y}, state.grid, rover_id)
    {:reply, response, %{state | grid: grid}}
  end

  def find_next_coordinates({x, y}, :up), do: {x, y + 1}
  def find_next_coordinates({x, y}, :down), do: {x, y - 1}
  def find_next_coordinates({x, y}, :left), do: {x - 1, y}
  def find_next_coordinates({x, y}, :right), do: {x + 1, y}

  defp reserve_coordinate(rover_id, {x, y}, prev_pos, grid) do
    case Map.get(grid, {x, y}) do
      nil ->
        {{:error, :invalid_xy}, grid}

      [] ->
        grid =
          case prev_pos do
            {nil, nil} ->
              Map.put(grid, {x, y}, [rover_id])

            _ ->
              grid |> Map.put(prev_pos, []) |> Map.put({x, y}, [rover_id])
          end

        {{:ok, {x, y}}, grid}

      _other ->
        {{:error, :already_reserved}, grid}
    end
  end

  def unreserve_coordinate({x, y}, grid, rover_id) do
    case Map.get(grid, {x, y}) do
      nil ->
        {{:error, :invalid_xy}, grid}

      [current_rover_id] when current_rover_id == rover_id ->
        {{:ok, :unreserved}, Map.put(grid, {x, y}, [])}

      _other ->
        {{:error, :not_reserved_by_rover}, grid}
    end
  end

  defp initialize_grid([x, y]) do
    ## x, y => 2, 2
    ## %{{0, 0} => [], {0, 1} => [], {1, 0} => [], {1, 1} => []}
    Enum.reduce(0..x, %{}, fn x_i, grid ->
      Enum.reduce(0..y, grid, fn y_j, grid ->
        Map.put(grid, {x_i, y_j}, [])
      end)
    end)
  end

  defp grid_size() do
    Application.get_env(:rover_app, :grid_size)
  end
end
