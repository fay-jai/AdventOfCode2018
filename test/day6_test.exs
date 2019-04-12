defmodule Day6Test do
  use ExUnit.Case

  alias AdventOfCode2018.Day6

  setup do
    coordinates = """
    8, 0
    2, 1
    7, 2
    1, 3
    3, 3
    5, 5
    3, 7
    9, 8
    0, 9
    """
    {:ok, coordinates: coordinates}
  end

  test "parse input coordinates correctly", state do
    actual = Day6.parse_input_into_coordinates_map(state.coordinates)
    expected = %{
      "0" => {8, 0},
      "1" => {2, 1},
      "2" => {7, 2},
      "3" => {1, 3},
      "4" => {3, 3},
      "5" => {5, 5},
      "6" => {3, 7},
      "7" => {9, 8},
      "8" => {0, 9}
    }

    assert actual == expected
  end

  test "retrieve coordinate keys correctly", state do
    actual =
      state.coordinates
      |> Day6.parse_input_into_coordinates_map()
      |> Day6.get_coordinates_keys()

    expected = ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
    assert actual == expected
  end

  test "retrieve coordinate values correctly", state do
    actual =
      state.coordinates
      |> Day6.parse_input_into_coordinates_map()
      |> Day6.get_coordinates_values()

    expected = [{8, 0}, {2, 1}, {7, 2}, {1, 3}, {3, 3}, {5, 5}, {3, 7}, {9, 8}, {0, 9}]
    assert actual == expected
  end

  test "retrieve coordinate with max x value correctly", state do
    actual =
      state.coordinates
      |> Day6.parse_input_into_coordinates_map()
      |> Day6.get_coordinates_values()
      |> Day6.max_coordinate("x")

    assert actual == {9, 8}
  end

  test "retrieve coordinate with max x value when there are multiple correctly" do
    coordinates = """
    8, 0
    2, 1
    7, 2
    1, 3
    9, 9
    3, 3
    5, 5
    3, 7
    9, 8
    0, 9
    """

    actual =
      coordinates
      |> Day6.parse_input_into_coordinates_map()
      |> Day6.get_coordinates_values()
      |> Day6.max_coordinate("x")

    assert actual == {9, 9}
  end

  test "retrieve coordinate with max y value correctly", state do
    actual =
      state.coordinates
      |> Day6.parse_input_into_coordinates_map()
      |> Day6.get_coordinates_values()
      |> Day6.max_coordinate("y")

    assert actual == {0, 9}
  end

  test "retrieve coordinate with max y value when there are multiple correctly" do
    coordinates = """
    8, 0
    2, 1
    7, 2
    1, 3
    0, 4
    3, 3
    5, 5
    3, 7
    9, 8
    0, 3
    """

    actual =
      coordinates
      |> Day6.parse_input_into_coordinates_map()
      |> Day6.get_coordinates_values()
      |> Day6.max_coordinate("y")

    assert actual == {9, 8}
  end

  test "retrieve grid coordinates correctly" do
    coordinates = """
    1, 0
    2, 3
    """

    actual =
      coordinates
      |> Day6.parse_input_into_coordinates_map()
      |> Day6.get_coordinates_values()
      |> Day6.grid_coordinates()

    assert actual == [
      [{0, 0}, {1, 0}, {2, 0}],
      [{0, 1}, {1, 1}, {2, 1}],
      [{0, 2}, {1, 2}, {2, 2}],
      [{0, 3}, {1, 3}, {2, 3}]
    ]
  end

  test "manhattan distance between 2 points" do
    point_a = {194, 200}
    point_b = {299, 244}

    assert Day6.manhattan_distance(point_a, point_b) == (299 - 194) + (244 - 200)
  end

  test "retrieve closest input coordinate for a grid coordinate" do
    coordinates = """
    1, 0
    2, 3
    """

    coordinates_map = Day6.parse_input_into_coordinates_map(coordinates)
    actual = Day6.get_closest_input_coordinate({1, 1}, coordinates_map)
    expected = "0"

    assert actual == expected
  end

  test "produce grid map correctly", state do
    actual = state.coordinates |> Day6.parse_input_into_coordinates_map() |> Day6.produce_grid_map()

    expected = [
      ["1", "1", "1", "1", "1", "0", "0", "0", "0", "0"],
      ["1", "1", "1", "1", "1", ".", "2", "2", "0", "0"],
      ["3", "3", "1", "4", "4", "2", "2", "2", "2", "2"],
      ["3", "3", ".", "4", "4", ".", "2", "2", "2", "2"],
      ["3", "3", ".", "4", ".", "5", "5", "2", "2", "."],
      ["3", "3", ".", ".", "5", "5", "5", "5", "5", "7"],
      ["8", ".", "6", "6", ".", "5", "5", "5", "7", "7"],
      ["8", "6", "6", "6", "6", ".", ".", "7", "7", "7"],
      ["8", "8", "6", "6", "6", ".", "7", "7", "7", "7"],
      ["8", "8", "8", "6", "6", ".", "7", "7", "7", "7"],
    ]

    assert actual == expected
  end

  test "retrieve correct coordinate labels on perimeter of grid map", state do
    grid_map = state.coordinates |> Day6.parse_input_into_coordinates_map() |> Day6.produce_grid_map()

    actual = grid_map |> Day6.coordinates_on_perimeter_of_grid_map()
    expected = MapSet.new([".", "0", "1", "2", "3", "6", "7", "8"])

    assert actual == expected
  end
end
