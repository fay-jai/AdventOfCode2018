defmodule Day6Test do
  use ExUnit.Case

  alias AdventOfCode2018.Day6

  test "manhattan distance between 2 points" do
      point_a = {194, 200}
      point_b = {299, 244}

      assert AdventOfCode2018.Day6.manhattan_distance(point_a, point_b) == (299 - 194) + (244 - 200)
  end
end
