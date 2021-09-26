defmodule GenReport do
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
    "reports/#{filename}"
    |> File.stream!()
    |> Enum.reduce(report_acc(), fn line, report ->
      [worker, worked_hours, _day, _month, _year] = parse_line(line)
      Map.put(report, worker, report[worker] + worked_hours)
    end)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> List.update_at(1, &String.to_integer/1)
  end

  defp report_acc, do: Enum.into(@workers, %{}, &{&1, 0})
end
