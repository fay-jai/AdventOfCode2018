defmodule AdventOfCode2018.Day7 do
  alias AdventOfCode2018.Day7.Step
  alias AdventOfCode2018.Helpers

  @num_workers 5
  @job_times %{
    "A" => 61,
    "B" => 62,
    "C" => 63,
    "D" => 64,
    "E" => 65,
    "F" => 66,
    "G" => 67,
    "H" => 68,
    "I" => 69,
    "J" => 70,
    "K" => 71,
    "L" => 72,
    "M" => 73,
    "N" => 74,
    "O" => 75,
    "P" => 76,
    "Q" => 77,
    "R" => 78,
    "S" => 79,
    "T" => 80,
    "U" => 81,
    "V" => 82,
    "W" => 83,
    "X" => 84,
    "Y" => 85,
    "Z" => 86,
  }

  def part1() do
    Helpers.read_file(7)
    |> build_steps_struct()
    |> process_steps([])
    |> List.to_string()
  end

  def parse_steps(steps_input) do
    steps_input
    |> String.split("\n", trim: true)
    |> Enum.map(fn (<< "Step ", parent::bytes-size(1), " must be finished before step ", child::bytes-size(1), " can begin." >>) -> [parent, child] end)
  end

  def build_steps_struct(steps_input) do
    steps_input
    |> parse_steps()
    |> Enum.reduce(%{}, fn ([parent, child], memo) ->
      parent_value = Map.get(memo, parent, %Step{job: parent})
      child_value = Map.get(memo, child, %Step{job: child})

      memo
      |> Map.put(parent, %{ parent_value | children: MapSet.put(parent_value.children, child) })
      |> Map.put(child, %{ child_value | parents: MapSet.put(child_value.parents, parent) })
    end)
  end

  # Part 1 Helpers
  def get_next_step(steps_map) do
    steps_map
    |> Enum.filter(fn ({_, %Step{parents: parents}}) -> MapSet.size(parents) == 0 end)
    |> Enum.map(fn ({job, _step = %Step{}}) -> job end)
    |> Enum.sort()
    |> List.first()
  end

  def delete_step(steps_map, step) do
    updated_steps_map = steps_map |> Map.delete(step)

    Map.get(steps_map, step).children
    |>  MapSet.to_list()
    |>  Enum.reduce(updated_steps_map, fn (child, memo) ->
          Map.put(
            memo,
            child,
            %Step{ Map.get(memo, child) | parents: MapSet.delete(Map.get(memo, child).parents, step) }
          )
        end)
  end

  def process_steps(steps_map, results) when map_size(steps_map) == 0, do: Enum.reverse(results)
  def process_steps(steps_map, results) do
    next_step = get_next_step(steps_map)

    steps_map
    |> delete_step(next_step)
    |> process_steps([next_step | results])
  end

  # Part 2 Helpers
  def part2(steps_map, steps_in_progress, current_time) do
    # For each step in steps_in_progress:
      # If step is completed as of current_time, then update steps_map by deleting step and removing step from steps_in_progress
    # While steps_in_progress has space to take on additional steps and there are steps available:
        # Update steps_map to add an end_time to the step and add step to steps_in_progress
    # Recursively call part2 with current_time + 1
  end

  def get_next_available_steps(steps_map) do
    steps_map
    |> Enum.filter(fn ({_, %Step{parents: parents, end_time: end_time}}) -> MapSet.size(parents) == 0 && is_nil(end_time) end)
    |> Enum.map(fn ({job, _step = %Step{}}) -> job end)
    |> Enum.sort()
  end

  def can_handle_more_steps?(steps_in_progress), do: MapSet.size(steps_in_progress) < @num_workers

  def start_step(steps_map, step, current_time) do
    updated_step_struct = %{Map.get(steps_map, step) | end_time: current_time + @job_times[step] - 1}
    Map.put(steps_map, step, updated_step_struct)
  end

  def is_step_completed?(steps_map, step, current_time) do
    end_time = steps_map[step].end_time
    if is_nil(end_time), do: false, else: end_time < current_time
  end

  def delete_step_part2(steps_map, steps_in_progress, step, current_time) do
    if is_step_completed?(steps_map, step, current_time) do
      {delete_step(steps_map, step), MapSet.delete(steps_in_progress, step)}
    else
      {steps_map, steps_in_progress}
    end
  end

  def delete_completed_steps(steps_map, steps_in_progress, current_time) do
    steps_in_progress
    |> MapSet.to_list()
    |> Enum.reduce({steps_map, steps_in_progress}, fn (step, {sm, sip}) ->
      delete_step_part2(sm, sip, step, current_time)
    end)
  end

  def add_steps(steps_map, steps_in_progress, current_time) do
    _add_steps(
      steps_map,
      steps_in_progress,
      current_time,
      can_handle_more_steps?(steps_in_progress),
      steps_map |> get_next_available_steps() |> length() > 0
    )
  end

  def _add_steps(steps_map, steps_in_progress, current_time, _workers_available = true, _steps_available = true) do
    [next_step | _] = get_next_available_steps(steps_map)

    updated_steps_map = start_step(steps_map, next_step, current_time)
    updated_steps_in_progress = MapSet.put(steps_in_progress, next_step)

    _add_steps(
      updated_steps_map,
      updated_steps_in_progress,
      current_time,
      can_handle_more_steps?(updated_steps_in_progress),
      updated_steps_map |> get_next_available_steps() |> length() > 0
    )
  end
  def _add_steps(steps_map, steps_in_progress, _, _, _), do: {steps_map, steps_in_progress}
end
