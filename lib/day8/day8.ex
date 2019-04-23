defmodule AdventOfCode2018.Day8 do
  alias AdventOfCode2018.Helpers

  def part1() do
    Helpers.read_file(8)
    |> parse_tree()
    |> recurse()
    |> List.flatten()
    |> Enum.reduce(0, fn (num, memo) -> num + memo end)
  end

  def parse_tree(tree_txt) do
    tree_txt
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  # Part 1 Helpers
  def recurse(data) do
    {_, results} = _recurse(data, [])
    results
  end

  defp _recurse([_num_children = 0, num_metadata | rest], results) do
    {metadata, updated_rest} = Enum.split(rest, num_metadata)
    {updated_rest, [metadata | results]}
  end
  defp _recurse([num_children, num_metadata | rest], results) do
    {updated_rest, updated_results} = _recurse(rest, results)
    _recurse([num_children - 1, num_metadata | updated_rest], updated_results)
  end
end
