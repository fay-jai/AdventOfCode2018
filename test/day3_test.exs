defmodule Day3Test do
  use ExUnit.Case

  alias AdventOfCode2018.Day3.Claim

  test "convert a line to a claim" do
      line = "#1 @ 493,113: 12x14"
      expected_claim = %Claim{
          id: 1,
          x_cord: 493,
          y_cord: 113,
          width: 12,
          height: 14
      }
      assert AdventOfCode2018.Day3.convert_line_to_claim(line) == expected_claim
  end

  test "get claimed coordinates from claim" do
      line = "#1 @ 1,1: 3x4"
      claim = AdventOfCode2018.Day3.convert_line_to_claim(line)
      claimed_coordinates = AdventOfCode2018.Day3.get_claimed_coordinates_from_claim(claim)
      expected_claimed_coordinates = [
          {1, 1},
          {2, 1},
          {3, 1},
          {1, 2},
          {2, 2},
          {3, 2},
          {1, 3},
          {2, 3},
          {3, 3},
          {1, 4},
          {2, 4},
          {3, 4}
      ]
      assert MapSet.new(claimed_coordinates) == MapSet.new(expected_claimed_coordinates)
  end

  test "get hash of claimed coordinates" do
      claimed_coordinates1 =
          "#1 @ 1,1: 3x4"
          |> AdventOfCode2018.Day3.convert_line_to_claim()
          |> AdventOfCode2018.Day3.get_claimed_coordinates_from_claim()

      # claimed_coordinates2 = [
      #     {1, 1},
      #     {2, 1},
      #     {1, 2},
      #     {2, 2}
      # ]
      claimed_coordinates2 =
          "#2 @ 1,1: 2x2"
          |> AdventOfCode2018.Day3.convert_line_to_claim()
          |> AdventOfCode2018.Day3.get_claimed_coordinates_from_claim()

      all_claimed_coordinates = claimed_coordinates1 ++ claimed_coordinates2

      actual_hash = AdventOfCode2018.Day3.get_hash_of_claimed_coordinates(all_claimed_coordinates)
      expected_hash = %{
          {1, 1} => 2,
          {2, 1} => 2,
          {3, 1} => 1,
          {1, 2} => 2,
          {2, 2} => 2,
          {3, 2} => 1,
          {1, 3} => 1,
          {2, 3} => 1,
          {3, 3} => 1,
          {1, 4} => 1,
          {2, 4} => 1,
          {3, 4} => 1
      }

      assert actual_hash == expected_hash
  end
end