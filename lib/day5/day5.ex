defmodule AdventOfCode2018.Day5 do
  alias AdventOfCode2018.Helpers

  def part1() do
    Helpers.read_file_and_parse(5)
    |> List.first()
    |> recurse()
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