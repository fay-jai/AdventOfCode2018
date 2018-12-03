defmodule AdventOfCode2018.Day2 do
  @input_path Path.join(File.cwd!(), "assets/day2_input.txt")

  @doc """
  You scan the likely candidate boxes, counting the number that have an ID containing exactly two of any letter and then separately counting those with exactly three of any letter.
  You can multiply those two counts together to get a rudimentary checksum and compare it to what your device predicts.

  For example, if you see the following box IDs:

    abcdef contains no letters that appear exactly two or three times.
    bababc contains two a and three b, so it counts for both.
    abbcde contains two b, but no letter appears exactly three times.
    abcccd contains three c, but no letter appears exactly two times.
    aabcdd contains two a and two d, but it only counts once.
    abcdee contains two e.
    ababab contains three a and three b, but it only counts once.

  Of these box IDs, four of them contain a letter which appears exactly twice, and three of them contain a letter which appears exactly three times. Multiplying these together produces a checksum of 4 * 3 = 12.

  What is the checksum for your list of box IDs?
  """
  def part1 do
    @input_path
    |> process_file
  end

  defp process_file(file) do
    file
    |> File.read!
    |> String.split(~r/\n/)
  end
end