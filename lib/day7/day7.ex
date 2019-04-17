defmodule AdventOfCode2018.Day7 do
  alias AdventOfCode2018.Helpers

  def parse_steps(steps_input) do
    steps_input
    |> String.split("\n", trim: true)
    |> Enum.map(fn (<< "Step ", parent::bytes-size(1), " must be finished before step ", child::bytes-size(1), " can begin." >>) -> [parent, child] end)
  end

  def distinct_steps(steps) do
    steps |> List.flatten() |> MapSet.new()
  end
end
