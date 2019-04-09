defmodule AdventOfCode2018.Day6 do
  alias AdventOfCode2018.Helpers

  def part1() do
    Helpers.read_file_and_parse(6)
  end

  def parse_input_into_coordinates() do
    Helpers.read_file_and_parse(6)
    |>  Enum.map(fn (string) ->
          [x, y] = String.split(string, ", ")
          {x, y}
        end)
  end
end