defmodule AdventOfCode2018.Day5 do
  alias AdventOfCode2018.Helpers

  @letters ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

  def part1() do
    get_initial_unreacted_polymer()
    |> recurse()
  end

  def part2() do
    unreacted_polymer = get_initial_unreacted_polymer()

    Enum.reduce(@letters, %{}, fn (letter, hash) ->
      reduced_polymer = remove_unit_type_from_polymer(unreacted_polymer, letter)
      fully_reacted_polymer = recurse(reduced_polymer)

      Map.put(hash, letter, String.length(fully_reacted_polymer))
    end)
  end

  def get_initial_unreacted_polymer() do
    Helpers.read_file_and_parse(5)
    |> List.first()
  end

  def remove_unit_type_from_polymer(polymer, unit) do
    polymer
    |> String.split("", trim: true)
    |> Enum.reject(fn (char) -> char == String.upcase(unit) || char == String.downcase(unit) end)
    |> Enum.join("")
  end

  def units_react?(unit, unit), do: false
  def units_react?(unit1, unit2), do: String.upcase(unit1) == unit2 || String.downcase(unit1) == unit2

  def react(polymer) when is_binary(polymer), do: react({ polymer, 0 })
  def react({ "", num_reactions }), do: { "", num_reactions }
  def react({ << letter::bytes-size(1) >>, num_reactions }), do: { letter, num_reactions }
  def react({ << first::bytes-size(1), second::bytes-size(1), rest::binary >>, num_reactions }) do
    if units_react?(first, second) do
      react({ rest, num_reactions + 1 })
    else
      { result, total } = react({ second <> rest, num_reactions })
      { first <> result, total }
    end
  end

  def recurse(polymer) do
    { result, num_reactions } = react(polymer)

    if num_reactions == 0, do: result, else: recurse(result)
  end
end