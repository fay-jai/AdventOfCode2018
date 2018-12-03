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
    data = @input_path |> process_file |> Enum.map(&produce_string_hash/1)

    num_two = data |> get_count(2)
    num_three = data |> get_count(3)

    num_two * num_three
  end

  @doc """
  With part 1 complete, you're ready to find the boxes full of prototype fabric.

  The boxes will have IDs which differ by exactly one character at the same position in both strings. For example, given the following box IDs:

    abcde
    fghij
    klmno
    pqrst
    fguij
    axcye
    wvxyz

  The IDs abcde and axcye are close, but they differ by two characters (the second and fourth). However, the IDs fghij and fguij differ by exactly one character, the third (h and u). Those must be the correct boxes.

  What letters are common between the two correct box IDs? (In the example above, this is found by removing the differing character from either ID, producing fgij.)
  """
  def part2 do
    [correct_box1, correct_box2] =
      @input_path
      |> process_file
      |> get_correct_boxes

    get_common_characters(correct_box1, correct_box2)
  end

  defp process_file(file) do
    file
    |> File.read!
    |> String.split(~r/\n/)
  end

  defp produce_string_hash(string) do
    string
    |> String.split("", trim: true)
    |> Enum.reduce(%{}, fn (char, acc) ->
      char_count = if Map.has_key?(acc, char), do: acc[char] + 1, else: 1
      Map.put(acc, char, char_count)
    end)
  end

  defp get_count(data, num) do
    data
    |> Enum.map(fn (letter_hash) -> num in (letter_hash |> Map.values) end)
    |> Enum.filter(&(&1 == true))
    |> Enum.count
  end

  defp get_correct_boxes([]), do: []
  defp get_correct_boxes([first_box | rest_boxes]) do
    result = rest_boxes |> Enum.filter(fn (box) -> are_correct_boxes(first_box, box) end)

    if length(result) > 0 do
      [ found_box ] = result
      [ first_box, found_box ]
    else
      get_correct_boxes(rest_boxes)
    end
  end

  defp are_correct_boxes(box1, box2), do: are_correct_boxes(box1, box2, 0)

  defp are_correct_boxes("", "", num_off), do: num_off < 2
  defp are_correct_boxes(_, _, num_off) when num_off > 2, do: false
  defp are_correct_boxes(<< char1, rest1::binary >>, << char2, rest2::binary >>, num_off) when char1 == char2, do: are_correct_boxes(rest1, rest2, num_off)
  defp are_correct_boxes(<< _, rest1::binary >>, << _, rest2::binary >>, num_off), do: are_correct_boxes(rest1, rest2, num_off + 1)

  defp get_common_characters(box1, box2), do: get_common_characters(box1, box2, "")

  defp get_common_characters("", "", result), do: result
  defp get_common_characters(<< char1, rest1::binary >>, << char2, rest2::binary >>, result) when char1 == char2, do: get_common_characters(rest1, rest2, result <> << char1>>)
  defp get_common_characters(<< _, rest1::binary >>, << _, rest2::binary >>, result), do: get_common_characters(rest1, rest2, result)
end