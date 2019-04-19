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
  def get_next_available_steps(steps_map) do
    steps_map
    |> Enum.filter(fn ({_, %Step{parents: parents, end_time: end_time}}) -> MapSet.size(parents) == 0 && is_nil(end_time) end)
    |> Enum.map(fn ({job, _step = %Step{}}) -> job end)
    |> Enum.sort()
  end

  def workers_available?(workers), do: MapSet.size(workers) < @num_workers

  def start_step(steps_map, step, current_time) do
    updated_step_struct = %{Map.get(steps_map, step) | end_time: current_time + @job_times[step] - 1}
    Map.put(steps_map, step, updated_step_struct)
  end

  def is_step_completed?(steps_map, step, current_time) do
    end_time = steps_map[step].end_time
    if is_nil(end_time), do: false, else: end_time < current_time
  end

  def delete_step_part2(steps_map, step, current_time) do
    if is_step_completed?(steps_map, step, current_time) do
      delete_step(steps_map, step)
    else
      steps_map
    end
  end
end
