defmodule AdventOfCode2018.Day7 do
  alias AdventOfCode2018.Day7.Step
  alias AdventOfCode2018.Helpers

  def get_next_step(steps_map) do
    steps_map
    |> Enum.filter(fn ({job, %Step{parents: parents}}) -> MapSet.size(parents) == 0 end)
    |> Enum.map(fn ({job, _step = %Step{}}) -> job end)
    |> Enum.sort()
    |> List.first()
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

  def parse_steps(steps_input) do
    steps_input
    |> String.split("\n", trim: true)
    |> Enum.map(fn (<< "Step ", parent::bytes-size(1), " must be finished before step ", child::bytes-size(1), " can begin." >>) -> [parent, child] end)
  end
end
