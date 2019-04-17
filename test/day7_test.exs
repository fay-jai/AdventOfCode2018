defmodule Day7Test do
  use ExUnit.Case

  alias AdventOfCode2018.Day7

  setup do
    steps = """
    Step C must be finished before step A can begin.
    Step C must be finished before step F can begin.
    Step A must be finished before step B can begin.
    Step A must be finished before step D can begin.
    Step B must be finished before step E can begin.
    Step D must be finished before step E can begin.
    Step F must be finished before step E can begin.
    """
    {:ok, steps: steps}
  end

  test "parse input steps correctly", state do
    actual = Day7.parse_steps(state.steps)
    expected = [
      ["C", "A"],
      ["C", "F"],
      ["A", "B"],
      ["A", "D"],
      ["B", "E"],
      ["D", "E"],
      ["F", "E"]
    ]

    assert actual == expected
  end
end
