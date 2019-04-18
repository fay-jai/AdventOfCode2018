defmodule AdventOfCode2018.Day7.Step do
  defstruct job: "",
            parents: MapSet.new(),
            children: MapSet.new()
end
