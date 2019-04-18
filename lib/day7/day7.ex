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

  def worker_queue_available?(worker_queue) when length(worker_queue) < @num_workers, do: true
  def worker_queue_available?(__), do: false

  def add_step_to_worker_queue(worker_queue, _, _, _is_available = false), do: worker_queue
  def add_step_to_worker_queue(worker_queue, step, current_time, _is_available) do
    job = %{ job: step, start_time: current_time, end_time: current_time + @job_times[step] - 1 }
    [job | worker_queue]
  end

  def remove_completed_steps_from_worker_queue(worker_queue, current_time) do
    worker_queue |> Enum.reject(fn (%{end_time: end_time}) -> end_time < current_time end)
  end
end
