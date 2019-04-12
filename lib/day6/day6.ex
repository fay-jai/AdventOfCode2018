defmodule AdventOfCode2018.Day6 do
  alias AdventOfCode2018.Helpers

  def part1() do
    Helpers.read_file(6)
    |> build_coordinates_map()
    |> bounding_grid_with_closest_coordinate()
    |> interior_coordinates_counts()
    |> Map.values()
    |> Enum.max()
  end

  def part2() do
    coordinates_map =  Helpers.read_file(6) |> build_coordinates_map()

    coordinates_map
    |> get_coordinates()
    |> build_bounding_grid()
    |> bounding_grid_total_distances(coordinates_map)
    |> Enum.filter(fn (distance) -> distance < 10_000 end)
    |> Enum.count()
  end

  # General Helpers
  def build_coordinates_map(coordinates_data) do
    {_, coordinates_map } =
      coordinates_data
      |>  String.split("\n", trim: true)
      |>  Enum.reduce({0, %{}}, fn (string, {count, map}) ->
            [x, y] = String.split(string, ", ")

            coordinate_tuple = {String.to_integer(x), String.to_integer(y)}
            {count + 1, Map.put(map, "#{count}", coordinate_tuple)}
          end)

    coordinates_map
  end

  def get_coordinate_labels(coordinates_map), do: coordinates_map |> Map.keys()
  def get_coordinates(coordinates_map), do: coordinates_map |> Map.values()

  def build_bounding_grid(coordinates) do
    {max_x, _} = coordinates |> max_coordinate("x")
    {_, max_y} = coordinates |> max_coordinate("y")
    grid = for y <- 0..max_y, x <- 0..max_x, do: {x, y}

    Enum.chunk_every(grid, max_x + 1)
  end

  def max_coordinate(coordinates, "x") do
    coordinates
    |>  Enum.reduce(fn (coord, max_coord) ->
          if coord > max_coord, do: coord, else: max_coord
        end)
  end

  def max_coordinate(coordinates, "y") do
    coordinates
    |>  Enum.reduce(fn (coord, max_coord) ->
          {x_coord, y_coord} = coord
          {max_x_coord, max_y_coord} = max_coord

          if {y_coord, x_coord} > {max_y_coord, max_x_coord}, do: coord, else: max_coord
        end)
  end

  def manhattan_distance({x_a, y_a}, {x_b, y_b}), do: abs(x_a - x_b) + abs(y_a - y_b)

  def closest_coordinate(coordinate, coordinates_map) do
    coordinates_keys = get_coordinate_labels(coordinates_map)

    mds =
      coordinates_keys
        |>  Enum.map(fn (label) ->
              label_coordinate = Map.get(coordinates_map, label)
              {label, manhattan_distance(coordinate, label_coordinate)}
            end)

    {_, min_md} = Enum.reduce(mds, fn (current, acc) ->
      {_, md} = current
      {_, min} = acc

      if md < min, do: current, else: acc
    end)

    min_md_coordinates = Enum.filter(mds, fn ({ _, md }) -> md == min_md end)

    if length(min_md_coordinates) > 1 do
      "."
    else
      {label, _} = Enum.at(min_md_coordinates, 0)
      label
    end
  end

  def bounding_grid_with_closest_coordinate(coordinates_map) do
    coordinates_map
    |> get_coordinates()
    |> build_bounding_grid()
    |>  Enum.map(fn (row) ->
          Enum.map(row, fn (coordinate) -> closest_coordinate(coordinate, coordinates_map) end)
        end)
  end

  def perimeter_coordinates(grid_map) do
    num_rows = grid_map |> length()
    num_cols = grid_map |> Enum.at(0) |> length()

    first_row = Enum.at(grid_map, 0)
    last_row = Enum.at(grid_map, num_rows - 1)
    first_col = Enum.map(grid_map, fn (row) -> Enum.at(row, 0) end)
    last_col = Enum.map(grid_map, fn (row) -> Enum.at(row, num_cols - 1) end)

    MapSet.new(first_row ++ last_row ++ first_col ++ last_col)
  end

  def interior_coordinates_counts(grid_map) do
    exterior_coordinate_keys = perimeter_coordinates(grid_map)

    grid_map
    |> List.flatten()
    |> Enum.reject(fn (label) -> MapSet.member?(exterior_coordinate_keys, label) end)
    |> Enum.reduce(%{}, fn (label, memo) -> Map.update(memo, label, 1, &(&1 + 1)) end)
  end

  def total_manhattan_distance(coordinate, coordinates_map) do
    coordinates_map
    |> get_coordinates()
    |> Enum.reduce(0, fn (label_coordinate, total_distance) ->
      total_distance + manhattan_distance(coordinate, label_coordinate)
    end)
  end

  def bounding_grid_total_distances(bounding_grid, coordinates_map) do
    bounding_grid
    |> List.flatten()
    |> Enum.map(fn (coordinate) -> total_manhattan_distance(coordinate, coordinates_map) end)
  end
end
