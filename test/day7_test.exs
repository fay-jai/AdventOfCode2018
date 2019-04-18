defmodule Day7Test do
  use ExUnit.Case

  alias AdventOfCode2018.Day7
  alias AdventOfCode2018.Day7.Step

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

  test "get distinct steps correctly", state do
    actual = state.steps |> Day7.parse_steps() |> Day7.distinct_steps()
    expected = MapSet.new(["A", "B", "C", "D", "E", "F"])

    assert actual == expected
  end

  test "build steps struct correctly", state do
    expected = state.steps |> Day7.build_steps_struct()

    actual = %{
      "A" => %Step{ job: "A", parents: MapSet.new(["C"]), children: MapSet.new(["B", "D"]) },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]) },
      "C" => %Step{ job: "C", parents: MapSet.new(), children: MapSet.new(["A", "F"]) },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]) },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]) },
      "F" => %Step{ job: "F", parents: MapSet.new(["C"]), children: MapSet.new(["E"]) }
    }

    assert actual == expected
  end
end
