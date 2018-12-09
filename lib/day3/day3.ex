defmodule AdventOfCode2018.Day3 do
  alias AdventOfCode2018.Day3.Claim

  @input_path Path.join(File.cwd!(), "assets/day3_input.txt")

  def part1() do
    @input_path
    |> get_claimed_coordinates_hash()
    |> get_num_claims_greater_than_x(1)
  end

  def process_file(file) do
      file
      |> File.read!
      |> String.split(~r/\n/)
      |> Enum.reject(fn (line) -> line == "" end) # Hack because I don't know how to remove last new line in a file
  end

  def convert_line_to_claim(line) do
      [ id_string, _, x_y, h_w ] = String.split(line, " ")

      id = get_id(id_string)
      [ x_cord, y_cord ] = get_cords(x_y)
      [ width, height ] = get_width_height(h_w)

      %Claim{
          id: String.to_integer(id),
          x_cord: String.to_integer(x_cord),
          y_cord: String.to_integer(y_cord),
          width: String.to_integer(width),
          height: String.to_integer(height)
      }
  end

  def get_claimed_coordinates_from_claim(%Claim{x_cord: x_cord, y_cord: y_cord, width: width, height: height}) do
      for x <- x_cord..x_cord + width - 1, y <- y_cord..y_cord + height - 1, do: { x, y }
  end

  def get_hash_of_claimed_coordinates(claimed_coordinates) do
      Enum.reduce(claimed_coordinates, %{}, fn (cord, acc) ->
          count = Map.get(acc, cord, 0) + 1
          Map.put(acc, cord, count)
      end)
  end

  def get_num_claims_greater_than_x(hash, x) do
      hash
      |> Map.values()
      |> Enum.filter(&(&1 > x))
      |> Enum.count()
  end

  def get_claimed_coordinates_hash(file) do
      file
      |> process_file()
      |> Enum.map(&convert_line_to_claim/1)
      |> Enum.map(&get_claimed_coordinates_from_claim/1)
      |> List.flatten()
      |> get_hash_of_claimed_coordinates()
  end

  defp get_id(<< "#", id::binary >>), do: id

  defp get_cords(line) do
      line
      |> String.slice(0, String.length(line) - 1)
      |> String.split(",")
  end

  defp get_width_height(line), do: String.split(line, "x")
end