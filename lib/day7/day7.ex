defmodule AdventOfCode2018.Day7 do
  alias AdventOfCode2018.Day7.Step
  alias AdventOfCode2018.Helpers

  @typedoc """
  A step is a single letter string (i.e. "A").
  """
  @type step :: String.t()

  @typedoc """
  A steps_map consists of steps and their corresponding Step struct.
  """
  @type steps_map :: %{required(step) => %Step{}}

  @num_workers 5
  @jobs for n <- ?A..?Z, do: << n :: utf8 >>
  @job_times @jobs |> Enum.with_index(61) |> Enum.reduce(%{}, fn ({job, time}, memo) -> Map.put(memo, job, time) end)

  def part1() do
    Helpers.read_file(7)
    |> build_steps_struct()
    |> process_steps([])
    |> List.to_string()
  end

  def part2() do
    Helpers.read_file(7)
    |> build_steps_struct()
    |> total_time(MapSet.new(), 0)
  end

  @spec parse_steps(String.t()) :: [[step, ...]]
  def parse_steps(steps_input) do
    steps_input
    |> String.split("\n", trim: true)
    |> Enum.map(fn (<< "Step ", parent::bytes-size(1), " must be finished before step ", child::bytes-size(1), " can begin." >>) -> [parent, child] end)
  end

  @spec build_steps_struct([[step, ...]]) :: steps_map
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
  @spec get_next_step(steps_map) :: step
  def get_next_step(steps_map) do
    steps_map
    |> Enum.filter(fn ({_, %Step{parents: parents}}) -> MapSet.size(parents) == 0 end)
    |> Enum.map(fn ({job, _step = %Step{}}) -> job end)
    |> Enum.sort()
    |> List.first()
  end

  @spec delete_step(steps_map, step) :: steps_map
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

  @spec process_steps(steps_map, [step, ...]) :: [step, ...]
  def process_steps(steps_map, results) when map_size(steps_map) == 0, do: Enum.reverse(results)
  def process_steps(steps_map, results) do
    next_step = get_next_step(steps_map)

    steps_map
    |> delete_step(next_step)
    |> process_steps([next_step | results])
  end

  # Part 2 Helpers
  @spec total_time(steps_map, MapSet.t(step), integer) :: integer
  def total_time(steps_map, _, current_time) when map_size(steps_map) == 0, do: current_time - 1
  def total_time(steps_map, steps_in_progress, current_time) do
    {updated_steps_map, updated_steps_in_progress} = delete_completed_steps(steps_map, steps_in_progress, current_time)
    {updated_steps_map, updated_steps_in_progress} = add_steps(updated_steps_map, updated_steps_in_progress, current_time)
    total_time(updated_steps_map, updated_steps_in_progress, current_time + 1)
  end

  @spec get_next_available_steps(steps_map) :: [step, ...]
  def get_next_available_steps(steps_map) do
    steps_map
    |> Enum.filter(fn ({_, %Step{parents: parents, end_time: end_time}}) -> MapSet.size(parents) == 0 && is_nil(end_time) end)
    |> Enum.map(fn ({job, _step = %Step{}}) -> job end)
    |> Enum.sort()
  end

  @spec can_handle_more_steps?(MapSet.t(step)) :: boolean
  def can_handle_more_steps?(steps_in_progress), do: MapSet.size(steps_in_progress) < @num_workers

  @spec start_step(steps_map, step, integer) :: steps_map
  def start_step(steps_map, step, current_time) do
    updated_step_struct = %{Map.get(steps_map, step) | end_time: current_time + @job_times[step] - 1}
    Map.put(steps_map, step, updated_step_struct)
  end

  @spec is_step_completed?(steps_map, step, integer) :: boolean
  def is_step_completed?(steps_map, step, current_time) do
    end_time = steps_map[step].end_time
    if is_nil(end_time), do: false, else: end_time < current_time
  end

  @spec delete_step_part2(steps_map, MapSet.t(step), step, integer) :: {steps_map, MapSet.t(step)}
  def delete_step_part2(steps_map, steps_in_progress, step, current_time) do
    if is_step_completed?(steps_map, step, current_time) do
      {delete_step(steps_map, step), MapSet.delete(steps_in_progress, step)}
    else
      {steps_map, steps_in_progress}
    end
  end

  @spec delete_completed_steps(steps_map, MapSet.t(step), integer) :: {steps_map, MapSet.t(step)}
  def delete_completed_steps(steps_map, steps_in_progress, current_time) do
    # For each step in steps_in_progress:
      # If step is completed as of current_time, then update steps_map by deleting step and removing step from steps_in_progress

    steps_in_progress
    |> MapSet.to_list()
    |> Enum.reduce({steps_map, steps_in_progress}, fn (step, {sm, sip}) ->
      delete_step_part2(sm, sip, step, current_time)
    end)
  end

  @spec add_steps(steps_map, MapSet.t(step), integer) :: {steps_map, MapSet.t(step)}
  def add_steps(steps_map, steps_in_progress, current_time) do
    # While steps_in_progress has space to take on additional steps and there are steps available:
      # Update steps_map to add an end_time to the step and add step to steps_in_progress

    _add_steps(
      steps_map,
      steps_in_progress,
      current_time,
      can_handle_more_steps?(steps_in_progress),
      steps_map |> get_next_available_steps() |> length() > 0
    )
  end

  @spec _add_steps(steps_map, MapSet.t(step), integer, boolean, boolean) :: {steps_map, MapSet.t(step)}
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
