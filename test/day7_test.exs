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

  test "get next step correctly", state do
    expected = state.steps |> Day7.build_steps_struct() |> Day7.get_next_step()
    actual = "C"

    assert actual == expected
  end

  test "get next step correctly when there are multiple" do
    steps_map = %{
      "A" => %Step{ job: "A", parents: MapSet.new([]), children: MapSet.new(["B", "D"]) },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]) },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]) },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]) },
      "F" => %Step{ job: "F", parents: MapSet.new([]), children: MapSet.new(["E"]) }
    }

    expected = steps_map |> Day7.get_next_step()
    actual = "A"

    assert actual == expected
  end

  test "get next step correctly when there are none" do
    steps_map = %{}

    expected = steps_map |> Day7.get_next_step()
    actual = nil

    assert actual == expected
  end
end
