defmodule GenReport do
  alias GenReport.Parser

  @workers [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  @years [
    2016,
    2017,
    2018,
    2019,
    2020
  ]

  def build, do: {:error, "Insira o nome de um arquivo"}

  def build(filename) do
    filename
    |> Parser.parse_file()
    |> Enum.reduce(report_acc(), fn line, report -> sum_hours(line, report) end)
  end

  defp sum_hours(
         [worker, worked_hours, _day, month, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => hours_per_month,
           "hours_per_year" => hours_per_year
         } = report
       ) do
    all_hours = Map.put(all_hours, worker, all_hours[worker] + worked_hours)

    worker_per_month = hours_per_month[worker]
    worker_per_month = Map.put(worker_per_month, month, worker_per_month[month] + worked_hours)
    hours_per_month = Map.put(hours_per_month, worker, worker_per_month)

    worker_per_year = hours_per_year[worker]
    worker_per_year = Map.put(worker_per_year, year, worker_per_year[year] + worked_hours)
    hours_per_year = Map.put(hours_per_year, worker, worker_per_year)

    %{
      report
      | "all_hours" => all_hours,
        "hours_per_month" => hours_per_month,
        "hours_per_year" => hours_per_year
    }
  end

  defp report_acc do
    all_hours = Enum.into(@workers, %{}, &{&1, 0})
    months = Enum.into(@months, %{}, &{&1, 0})
    years = Enum.into(@years, %{}, &{&1, 0})
    hours_per_month = Enum.into(@workers, %{}, &{&1, months})
    hours_per_year = Enum.into(@workers, %{}, &{&1, years})

    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
