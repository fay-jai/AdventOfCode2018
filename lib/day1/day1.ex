defmodule AdventOfCode2018.Day1 do
  @input_path Path.join(File.cwd!(), "assets/day1_input.txt")

  def main do
    @input_path
    |> process_file
    |> Enum.sum
  end

  def process_file(file) do
    file
    |> File.read!()
    |> String.split(~r/\n/)
    |> Enum.map(&String.to_integer/1)
  end
end