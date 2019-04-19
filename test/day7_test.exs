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
    actual = state.steps |> Day7.build_steps_struct()

    expected = %{
      "A" => %Step{ job: "A", parents: MapSet.new(["C"]), children: MapSet.new(["B", "D"]), end_time: nil },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "C" => %Step{ job: "C", parents: MapSet.new(), children: MapSet.new(["A", "F"]), end_time: nil },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
      "F" => %Step{ job: "F", parents: MapSet.new(["C"]), children: MapSet.new(["E"]), end_time: nil }
    }

    assert actual == expected
  end

  test "get next step correctly", state do
    actual = state.steps |> Day7.build_steps_struct() |> Day7.get_next_step()
    expected = "C"

    assert actual == expected
  end

  test "get next step correctly when there are multiple" do
    steps_map = %{
      "A" => %Step{ job: "A", parents: MapSet.new([]), children: MapSet.new(["B", "D"]), end_time: nil },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
      "F" => %Step{ job: "F", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: nil }
    }

    actual = steps_map |> Day7.get_next_step()
    expected = "A"

    assert actual == expected
  end

  test "get next step correctly when there are none" do
    steps_map = %{}

    actual = steps_map |> Day7.get_next_step()
    expected = nil

    assert actual == expected
  end

  test "delete step correctly", state do
    steps_map = state.steps |> Day7.build_steps_struct()
    next_step = steps_map |> Day7.get_next_step()

    actual = Day7.delete_step(steps_map, next_step)
    expected = %{
      "A" => %Step{ job: "A", parents: MapSet.new([]), children: MapSet.new(["B", "D"]), end_time: nil },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
      "F" => %Step{ job: "F", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: nil }
    }

    assert actual == expected
  end

  test "process steps correctly", state do
    steps_map = state.steps |> Day7.build_steps_struct()

    actual = Day7.process_steps(steps_map, [])
    expected = ["C", "A", "B", "D", "F", "E"]

    assert actual == expected
  end

  test "add step to worker queue correctly" do
    actual = Day7.add_step_to_worker_queue([], "C", 0)
    expected = [%{job: "C", end_time: 62}]

    assert actual == expected
  end

  test "remove completed steps from worker queue correctly" do
    worker_queue = [
      %{job: "C", end_time: 62}
    ]

    Enum.each(0..62, fn (current_time) ->
      assert Day7.remove_completed_steps_from_worker_queue(worker_queue, current_time) == worker_queue
    end)

    assert Day7.remove_completed_steps_from_worker_queue(worker_queue, 63) == []
  end

  test "get available steps correctly", state do
    steps_map = state.steps |> Day7.build_steps_struct()

    # Initial case
    actual = Day7.get_next_available_steps(steps_map)
    expected = ["C"]
    assert actual == expected

    # Updated C's end_time
    steps_map = %{steps_map | "C" => %{Map.get(steps_map, "C") | end_time: 62}}
    actual = Day7.get_next_available_steps(steps_map)
    expected = []
    assert actual == expected

    # Removed C
    steps_map = Day7.delete_step(steps_map, "C")
    actual = Day7.get_next_available_steps(steps_map)
    expected = ["A", "F"]
    assert actual == expected

    # Updated A's end_time
    steps_map = %{steps_map | "A" => %{Map.get(steps_map, "A") | end_time: 63}}
    actual = Day7.get_next_available_steps(steps_map)
    expected = ["F"]
    assert actual == expected

    # Updated F's end_time
    steps_map = %{steps_map | "F" => %{Map.get(steps_map, "F") | end_time: 68}}
    actual = Day7.get_next_available_steps(steps_map)
    expected = []
    assert actual == expected
  end

  test "start step correctly", state do
    steps_map = state.steps |> Day7.build_steps_struct()

    actual = Day7.start_step(steps_map, "C", 62)
    expected = %{
      "A" => %Step{ job: "A", parents: MapSet.new(["C"]), children: MapSet.new(["B", "D"]), end_time: nil },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "C" => %Step{ job: "C", parents: MapSet.new(), children: MapSet.new(["A", "F"]), end_time: 62 },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
      "F" => %Step{ job: "F", parents: MapSet.new(["C"]), children: MapSet.new(["E"]), end_time: nil }
    }
    assert actual == expected
  end

  test "check whether step is completed is correct", state do
    steps_map = state.steps |> Day7.build_steps_struct()

    actual = Day7.is_step_completed?(steps_map, "C", 0)
    assert actual == false

    steps_map = Day7.start_step(steps_map, "C", 62)
    actual = Day7.is_step_completed?(steps_map, "C", 62)
    assert actual == false

    actual = Day7.is_step_completed?(steps_map, "C", 63)
    assert actual == true
  end

  test "delete step part 2 correctly", state do
    steps_map = state.steps |> Day7.build_steps_struct()

    actual = Day7.delete_step_part2(steps_map, "C", 0)
    assert actual == steps_map

    steps_map = Day7.start_step(steps_map, "C", 62)
    actual = Day7.delete_step_part2(steps_map, "C", 0)
    assert actual == steps_map

    actual = Day7.delete_step_part2(steps_map, "C", 62)
    assert actual == steps_map

    actual = Day7.delete_step_part2(steps_map, "C", 63)
    expected = %{
      "A" => %Step{ job: "A", parents: MapSet.new([]), children: MapSet.new(["B", "D"]), end_time: nil },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
      "F" => %Step{ job: "F", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: nil }
    }
    assert actual == expected
  end
end
