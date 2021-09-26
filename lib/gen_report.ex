defmodule GenReport do
  alias GenReport.Parser

  @workers [
    "Cleiton",
    "Daniele",
    "Danilo",
    "Diego",
    "Giuliano",
    "Jakeliny",
    "Joseph",
    "Mayk",
    "Rafael",
    "Vinicius"
  ]

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_hours(line, report) end)
  end

  defp sum_hours([worker, worked_hours, _day, _month, _year], report) do
    Map.put(report, worker, report[worker] + worked_hours)
  end

  defp report_acc, do: Enum.into(@workers, %{}, &{&1, 0})
end
