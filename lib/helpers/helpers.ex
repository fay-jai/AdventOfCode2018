defmodule AdventOfCode2018.Helpers do
    def read_file_and_parse(day) do
        Path.join(File.cwd!(), "assets/day#{day}_input.txt")
        |> File.read!
        |> String.split(~r/\n/)
    end
end
