defmodule AdventOfCode2018.Day6 do
  alias AdventOfCode2018.Helpers

  def part1() do
  end

  def bounding_coordinates() do
    coordinates_map = parse_input_into_coordinates_map(Helpers.read_file_and_parse(6))
    coordinates_keys = get_coordinates_keys(Helpers.read_file_and_parse(6))
    coordinates_values = get_coordinates_values(Helpers.read_file_and_parse(6))

    left = coordinates_values |> min_coordinate("x")
    right = coordinates_values |> max_coordinate("x")
    top = coordinates_values |> min_coordinate("y")
    bottom = coordinates_values |> max_coordinate("y")

    %{
      left: Enum.find(coordinates_keys, fn (key) -> Map.get(coordinates_map, key) == left end),
      right: Enum.find(coordinates_keys, fn (key) -> Map.get(coordinates_map, key) == right end),
      top: Enum.find(coordinates_keys, fn (key) -> Map.get(coordinates_map, key) == top end),
      bottom: Enum.find(coordinates_keys, fn (key) -> Map.get(coordinates_map, key) == bottom end)
    }
  end

  def get_closest_input_coordinate(coordinate) do
    coordinates_map = parse_input_into_coordinates_map(Helpers.read_file_and_parse(6))
    coordinates_keys = get_coordinates_keys(Helpers.read_file_and_parse(6))

    mds = coordinates_keys
    |>  Enum.map(fn (label) ->
          label_coordinate = Map.get(coordinates_map, label)
          {label, manhattan_distance(coordinate, label_coordinate)}
        end)

    min_md = Enum.reduce(mds, fn ({_, md}, min) ->
      if md < min, do: md, else: min
    end)

    min_md_coordinates = Enum.filter(mds, fn ({ _, md }) -> md == min_md end)

    if length(min_md_coordinates) > 1 do
      "."
    else
      {label, _} = Enum.at(min_md_coordinates, 0)
      label
    end
  end

  def parse_input_into_coordinates_map(coordinates_data) do
    {_, coordinates_map } =
      coordinates_data
      |>  String.split("\n", trim: true)
      |>  Enum.reduce({0, %{}}, fn (string, {count, map}) ->
            [x, y] = String.split(string, ", ")

            coordinate_tuple = {String.to_integer(x), String.to_integer(y)}
            {count + 1, Map.put(map, count, coordinate_tuple)}
          end)

    coordinates_map
  end

  def get_coordinates_keys(coordinates_data) do
    coordinates_data
    |> parse_input_into_coordinates_map()
    |> Map.keys()
  end

  def get_coordinates_values(coordinates_data) do
    coordinates_data
    |> parse_input_into_coordinates_map()
    |> Map.values()
  end

  def min_coordinate(coordinates, "x") do
    coordinates
    |>  Enum.reduce(fn (coord, min_coord) ->
          {x_coord, _} = coord
          {min_x_coord, _} = min_coord

          if x_coord < min_x_coord, do: coord, else: min_coord
        end)
  end

  def min_coordinate(coordinates, "y") do
    coordinates
    |>  Enum.reduce(fn (coord, min_coord) ->
          {_, y_coord} = coord
          {_, min_y_coord} = min_coord

          if y_coord < min_y_coord, do: coord, else: min_coord
        end)
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

  def grid_coordinates(coordinates) do
    {max_x, _} = coordinates |> max_coordinate("x")
    {_, max_y} = coordinates |> max_coordinate("y")
    for x <- 0..max_y, y <- 0..max_x, do: {x, y}
  end

  def manhattan_distance({x_a, y_a}, {x_b, y_b}) do
    abs(x_a - x_b) + abs(y_a - y_b)
  end
end
