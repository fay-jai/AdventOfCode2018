defmodule AdventOfCode2018.Day4 do
  alias AdventOfCode2018.Helpers

  @num_days_in_month %{
                        1 => 31,
                        2 => 28,
                        3 => 31,
                        4 => 30,
                        5 => 31,
                        6 => 30,
                        7 => 31,
                        8 => 31,
                        9 => 30,
                        10 => 31,
                        11 => 30,
                        12 => 31
                      }

  @awake true
  @asleep false

  def full_test_data() do
    Helpers.read_file_and_parse(4)
    |> Enum.sort()
  end

  def partial_test_data() do
    Helpers.read_file_and_parse(4)
    |> Enum.sort()
    |> Enum.slice(3, 5)
  end


  def part1() do
    { guard_id, _ } = get_guard_who_sleeps_the_most()

    { minute, _ } = get_minute_guard_sleeps_the_most(guard_id)

    String.to_integer(guard_id) * minute
  end

  def part2() do
    guard_id_to_day_hash = get_guard_id_to_day()

    guard_ids = Map.keys(guard_id_to_day_hash)

    Enum.each(guard_ids, fn (guard_id) ->
      IO.puts "Guard #: #{guard_id}"
      { minute, total } = get_minute_guard_sleeps_the_most(guard_id)
      IO.puts "Minute #: #{minute}"
      IO.puts "Total times: #{total}"
    end)
  end

  def get_guard_who_sleeps_the_most() do
    get_guard_id_to_day()
    |> Enum.reduce(%{}, fn ({ guard_id, dates }, hash) ->
        total_minutes_asleep =
          dates |> Enum.reduce(0, fn (date, total) -> get_specific_day_total_minutes_asleep(date) + total end)
        Map.put(hash, guard_id, total_minutes_asleep)
      end)
    |> Enum.max(fn ({ _, minutes }) -> minutes end)
  end

  def get_minute_guard_sleeps_the_most(guard_id) do
    days_guarded = Map.get(get_guard_id_to_day(), guard_id)

    full_schedule = get_day_to_awake_schedule()

    minute_to_total_days_slept_for_guard =
      days_guarded
      |> Enum.flat_map(fn (day) ->
          full_schedule
          |> Map.get(day)
          |> Enum.reduce([], fn ({ minute, status }, result) -> if status == @asleep, do: [minute | result], else: result end)
        end)
      |> Enum.reduce(%{}, fn (minute ,hash) -> Map.put(hash, minute, Map.get(hash, minute, 0) + 1) end)

    if minute_to_total_days_slept_for_guard == %{} do
      { nil, nil }
    else
      minute_to_total_days_slept_for_guard
      |> Enum.reduce(fn ({ minute, total }, { so_far_minute, so_far_total }) -> if so_far_total > total, do: { so_far_minute, so_far_total }, else: { minute, total } end)
    end
  end

  def get_guard_id_to_day() do
    Helpers.read_file_and_parse(4)
    |> Enum.sort()
    |> Enum.filter(&just_starting_shift/1)
    |> Enum.group_by(&get_guard_number/1, fn (timestamp) -> timestamp |> parse_timestamp() |> get_date() end)
  end

  def get_day_to_awake_schedule() do
    Helpers.read_file_and_parse(4)
    |> Enum.sort()
    |> Enum.group_by(fn (timestamp) -> timestamp |> parse_timestamp() |> get_date() end)
    |> Enum.reduce(%{}, fn ({ key, timestamps_for_date }, hash) -> Map.put(hash, key, process_daily_awake_schedule(timestamps_for_date)) end)
  end

  def process_daily_awake_schedule(timestamps_for_date) do
    timestamps_for_date
    |> Enum.chunk_by(&just_starting_shift/1)
    |> update_daily_awake_schedule()
  end

  def update_daily_awake_schedule(chunked_results) when length(chunked_results) <= 1, do: get_minutes()
  def update_daily_awake_schedule([_, fall_asleep_and_wake_up_shifts ]) do
    fall_asleep_and_wake_up_shifts
    |> Enum.chunk_every(2)
    |> Enum.reduce(get_minutes(), fn ([ fall_asleep_timestamp, wake_up_timestamp ], minutes_hash) ->
      %{ minute: fall_asleep_minute } = parse_timestamp(fall_asleep_timestamp)
      %{ minute: wake_up_minute } = parse_timestamp(wake_up_timestamp)

      Enum.reduce(fall_asleep_minute..wake_up_minute - 1, minutes_hash, fn (min, hash) -> Map.put(hash, min, @asleep) end)
    end)
  end

  def get_specific_day_to_awake_schedule(date) do
    Map.get(get_day_to_awake_schedule(), date)
  end

  def get_specific_day_total_minutes_asleep(date) do
    date
    |> get_specific_day_to_awake_schedule()
    |> Map.values()
    |> Enum.count(&(&1 == @asleep))
  end

  def parse_timestamp(timestamp) do
    rgx = ~r/\[(.*?)\]/ # capture everything in between [ and ]
    [_, << year::bytes-size(4), "-", month::bytes-size(2), "-", day::bytes-size(2), " ",  hour::bytes-size(2), ":", minute::bytes-size(2) >> ] = Regex.run(rgx, timestamp)

    %{
      year: String.to_integer(year),
      month: String.to_integer(month),
      day: String.to_integer(day),
      hour: String.to_integer(hour),
      minute: String.to_integer(minute)
    }
  end

  def get_date(%{ year: year, month: month, day: day, hour: hour }) when hour == 0, do: Enum.join([ year, month, day ], "-")
  def get_date(%{ year: year, month: month, day: day }) do
    if day == @num_days_in_month[month] do
      Enum.join([ year, month + 1, 1 ], "-")
    else
      Enum.join([ year, month, day + 1 ], "-")
    end
  end

  def get_guard_number(starting_shift_timestamp) do
    rgx = ~r/Guard #([\d]+)/ # capture guard id number
    [ _, guard_id ] = Regex.run(rgx, starting_shift_timestamp)
    guard_id
  end

  def just_starting_shift(timestamp), do: String.ends_with?(timestamp, "begins shift")
  def just_fell_asleep(timestamp), do: String.ends_with?(timestamp, "falls asleep")
  def just_woke_up(timestamp), do: String.ends_with?(timestamp, "wakes up")

  def get_minutes(), do: for x <- 0..59, into: %{}, do: { x, @awake }
end