defmodule AdventOfCode2018.Day1 do
  @input_path Path.join(File.cwd!(), "assets/day1_input.txt")

  @doc """
  Solution: 525
  """
  def part1 do
    @input_path
    |> process_file
    |> Enum.sum
  end

  @doc """
  Solution: 75749
  """
  def part2(num) do
    @input_path
    |> create_stream
    |> process_stream(num)
    |> find_duplicate
  end

  defp process_file(file) do
    file
    |> File.read!()
    |> String.split(~r/\n/)
    |> Enum.map(&String.to_integer/1)
  end

  defp create_stream(file) do
    file
    |> process_file
    |> Stream.cycle
  end

  defp process_stream(stream, num) do
    stream
    |> Stream.scan(0, &(&1 + &2))
    |> Stream.take(num)
    |> Enum.to_list
  end

  defp find_duplicate(list), do: find_duplicate(list, MapSet.new([0]))

  defp find_duplicate([], _), do: false
  defp find_duplicate([h|t], map_set) do
    case MapSet.member?(map_set, h) do
      true -> h
      false -> find_duplicate(t, MapSet.put(map_set, h))
    end
  end
end