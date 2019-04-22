defmodule AdventOfCode2018.Day8 do
  alias AdventOfCode2018.Helpers

  def parse_tree(tree_txt) do
    tree_txt
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end
