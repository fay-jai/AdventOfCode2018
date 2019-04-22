defmodule Day8Test do
  use ExUnit.Case

  alias AdventOfCode2018.Day8

  setup do
    tree = """
    2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
    """
    {:ok, tree: tree}
  end

  test "parse input tree correctly", state do
    actual = Day8.parse_tree(state.tree)
    expected = [2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2]

    assert actual == expected
  end
end
