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

    actual = Day7.start_step(steps_map, "C", 0)
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

    steps_map = Day7.start_step(steps_map, "C", 0)
    actual = Day7.is_step_completed?(steps_map, "C", 62)
    assert actual == false

    actual = Day7.is_step_completed?(steps_map, "C", 63)
    assert actual == true
  end

  test "delete step part 2 correctly", state do
    steps_map = state.steps |> Day7.build_steps_struct()

    actual = Day7.delete_step_part2(steps_map, MapSet.new(), "C", 0)
    assert actual == {steps_map, MapSet.new()}

    steps_map = Day7.start_step(steps_map, "C", 0)
    actual = Day7.delete_step_part2(steps_map, MapSet.new(["C"]), "C", 0)
    assert actual == {steps_map, MapSet.new(["C"])}

    actual = Day7.delete_step_part2(steps_map, MapSet.new(["C"]), "C", 62)
    assert actual == {steps_map, MapSet.new(["C"])}

    actual = Day7.delete_step_part2(steps_map, MapSet.new(["C"]), "C", 63)
    expected = {
      %{
        "A" => %Step{ job: "A", parents: MapSet.new([]), children: MapSet.new(["B", "D"]), end_time: nil },
        "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
        "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
        "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
        "F" => %Step{ job: "F", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: nil }
      },
      MapSet.new()
    }
    assert actual == expected
  end

  test "delete completed steps correctly", state do
    steps_map = state.steps |> Day7.build_steps_struct()

    # Initial set up
    actual = Day7.delete_completed_steps(steps_map, MapSet.new(), 0)
    expected = {steps_map, MapSet.new()}
    assert actual == expected

    # Start of step C (current time = 0)
    updated_steps_map = Day7.start_step(steps_map, "C", 0)
    actual = Day7.delete_completed_steps(updated_steps_map, MapSet.new(["C"]), 0)
    expected = {updated_steps_map, MapSet.new(["C"])}
    assert actual == expected

    # Almost end of step C (current time = 62)
    actual = Day7.delete_completed_steps(updated_steps_map, MapSet.new(["C"]), 62)
    expected = {updated_steps_map, MapSet.new(["C"])}
    assert actual == expected

    # End of step C (current time = 63)
    actual = Day7.delete_completed_steps(updated_steps_map, MapSet.new(["C"]), 63)
    expected = {
      %{
        "A" => %Step{ job: "A", parents: MapSet.new([]), children: MapSet.new(["B", "D"]), end_time: nil },
        "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
        "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
        "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
        "F" => %Step{ job: "F", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: nil }
      },
      MapSet.new()
    }
    assert actual == expected
  end

  test "add steps correctly", state do
    steps_map = state.steps |> Day7.build_steps_struct()
    steps_in_progress = MapSet.new()

    # At current_time = 0
    actual = Day7.add_steps(steps_map, steps_in_progress, 0)
    updated_steps_map = %{
      "A" => %Step{ job: "A", parents: MapSet.new(["C"]), children: MapSet.new(["B", "D"]), end_time: nil },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "C" => %Step{ job: "C", parents: MapSet.new(), children: MapSet.new(["A", "F"]), end_time: 62 },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
      "F" => %Step{ job: "F", parents: MapSet.new(["C"]), children: MapSet.new(["E"]), end_time: nil }
    }
    updated_steps_in_progress = MapSet.new(["C"])
    expected = {updated_steps_map, updated_steps_in_progress}
    assert actual == expected

    # From current_time = 1 through current_time = 62
    Enum.each(1..62, fn (current_time) ->
      actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, current_time)
      expected = {updated_steps_map, updated_steps_in_progress}
      assert actual == expected
    end)

    # At current_time = 63, delete "C" first
    {updated_steps_map, updated_steps_in_progress} = Day7.delete_completed_steps(updated_steps_map, updated_steps_in_progress, 63)
    actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, 63)
    updated_steps_map = %{
      "A" => %Step{ job: "A", parents: MapSet.new(), children: MapSet.new(["B", "D"]), end_time: 123 },
      "B" => %Step{ job: "B", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "D" => %Step{ job: "D", parents: MapSet.new(["A"]), children: MapSet.new(["E"]), end_time: nil },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
      "F" => %Step{ job: "F", parents: MapSet.new(), children: MapSet.new(["E"]), end_time: 128 }
    }
    updated_steps_in_progress = MapSet.new(["A", "F"])
    assert actual == {updated_steps_map, updated_steps_in_progress}

    # From current_time = 64 through current_time = 123
    Enum.each(64..123, fn (current_time) ->
      actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, current_time)
      expected = {updated_steps_map, updated_steps_in_progress}
      assert actual == expected
    end)

    # At current_time = 124, delete "A" first
    {updated_steps_map, updated_steps_in_progress} = Day7.delete_completed_steps(updated_steps_map, updated_steps_in_progress, 124)
    actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, 124)
    updated_steps_map = %{
      "B" => %Step{ job: "B", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: 185 },
      "D" => %Step{ job: "D", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: 187 },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D", "F"]), children: MapSet.new([]), end_time: nil },
      "F" => %Step{ job: "F", parents: MapSet.new(), children: MapSet.new(["E"]), end_time: 128 }
    }
    updated_steps_in_progress = MapSet.new(["B", "D", "F"])
    assert actual == {updated_steps_map, updated_steps_in_progress}

    # From current_time = 125 through current_time = 128
    Enum.each(125..128, fn (current_time) ->
      actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, current_time)
      expected = {updated_steps_map, updated_steps_in_progress}
      assert actual == expected
    end)

    # At current_time = 129, delete "F" first
    {updated_steps_map, updated_steps_in_progress} = Day7.delete_completed_steps(updated_steps_map, updated_steps_in_progress, 129)
    actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, 129)
    updated_steps_map = %{
      "B" => %Step{ job: "B", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: 185 },
      "D" => %Step{ job: "D", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: 187 },
      "E" => %Step{ job: "E", parents: MapSet.new(["B", "D"]), children: MapSet.new([]), end_time: nil },
    }
    updated_steps_in_progress = MapSet.new(["B", "D"])
    assert actual == {updated_steps_map, updated_steps_in_progress}

    # From current_time = 130 through current_time = 185
    Enum.each(130..185, fn (current_time) ->
      actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, current_time)
      expected = {updated_steps_map, updated_steps_in_progress}
      assert actual == expected
    end)

    # At current_time = 186, delete "B" first
    {updated_steps_map, updated_steps_in_progress} = Day7.delete_completed_steps(updated_steps_map, updated_steps_in_progress, 186)
    actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, 186)
    updated_steps_map = %{
      "D" => %Step{ job: "D", parents: MapSet.new([]), children: MapSet.new(["E"]), end_time: 187 },
      "E" => %Step{ job: "E", parents: MapSet.new(["D"]), children: MapSet.new([]), end_time: nil },
    }
    updated_steps_in_progress = MapSet.new(["D"])
    assert actual == {updated_steps_map, updated_steps_in_progress}

    # At current_time = 187
    actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, 187)
    expected = {updated_steps_map, updated_steps_in_progress}
    assert actual == expected

    # At current_time = 188, delete "D" first
    {updated_steps_map, updated_steps_in_progress} = Day7.delete_completed_steps(updated_steps_map, updated_steps_in_progress, 188)
    actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, 188)
    updated_steps_map = %{
      "E" => %Step{ job: "E", parents: MapSet.new(), children: MapSet.new(), end_time: 252 },
    }
    updated_steps_in_progress = MapSet.new(["E"])
    assert actual == {updated_steps_map, updated_steps_in_progress}

    # From current_time = 189 through current_time = 252
    Enum.each(189..252, fn (current_time) ->
      actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, current_time)
      expected = {updated_steps_map, updated_steps_in_progress}
      assert actual == expected
    end)

    # At current_time = 253, delete "E" first
    {updated_steps_map, updated_steps_in_progress} = Day7.delete_completed_steps(updated_steps_map, updated_steps_in_progress, 253)
    actual = Day7.add_steps(updated_steps_map, updated_steps_in_progress, 253)
    updated_steps_map = %{}
    updated_steps_in_progress = MapSet.new()
    assert actual == {updated_steps_map, updated_steps_in_progress}
  end
end
