defmodule AdventOfCode2018.Day6 do
  alias AdventOfCode2018.Helpers

  def part1() do
    Helpers.read_file_and_parse(6)
  end

  def parse_input_into_coordinates() do
    Helpers.read_file_and_parse(6)
    |>  Enum.map(fn (string) ->
          [x, y] = String.split(string, ", ")
          {String.to_integer(x), String.to_integer(y)}
        end)
  end

  def manhattan_distance({x_a, y_a}, {x_b, y_b}) do
    abs(x_a - x_b) + abs(y_a - y_b)
  end

  def max_coordinate(coordinates, "x") do
    coordinates
    |>  Enum.reduce(fn (coord, max_coord) ->
          {x_coord, _} = coord
          {max_x_coord, _} = max_coord

          if x_coord > max_x_coord, do: coord, else: max_coord
        end)
  end

  def max_coordinate(coordinates, "y") do
    coordinates
    |>  Enum.reduce(fn (coord, max_coord) ->
          {_, y_coord} = coord
          {_, max_y_coord} = max_coord

          if y_coord > max_y_coord, do: coord, else: max_coord
        end)
  end

  def grid_coordinates(coordinates) do
    {max_x, _} = coordinates |> max_coordinate("x")
    {_, max_y} = coordinates |> max_coordinate("y")
    for x <- 0..max_x, y <- 0..max_y, do: {x, y}
  end
end
