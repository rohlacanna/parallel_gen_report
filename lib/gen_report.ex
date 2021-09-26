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

  def build_from_many do
    {:error, "Please, provide a list of strings."}
  end

  def build_from_many(filenames) when not is_list(filenames) do
    {:error, "Please, provide a list of strings."}
  end

  def build_from_many(filenames) do
    filenames
    |> Task.async_stream(&build/1)
    |> Enum.reduce(report_acc(), fn {:ok, result}, report -> sum_reports(report, result) end)
  end

  defp sum_hours(
         [worker, worked_hours, _day, month, year],
         %{
           "all_hours" => all_hours,
           "hours_per_month" => hours_per_month,
           "hours_per_year" => hours_per_year
         }
       ) do
    all_hours = Map.put(all_hours, worker, all_hours[worker] + worked_hours)

    worker_per_month = hours_per_month[worker]
    worker_per_month = Map.put(worker_per_month, month, worker_per_month[month] + worked_hours)
    hours_per_month = Map.put(hours_per_month, worker, worker_per_month)

    worker_per_year = hours_per_year[worker]
    worker_per_year = Map.put(worker_per_year, year, worker_per_year[year] + worked_hours)
    hours_per_year = Map.put(hours_per_year, worker, worker_per_year)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)

    hours_per_month =
      Enum.reduce(@workers, months_per_worker_acc(), fn worker, report ->
        Map.put(report, worker, merge_maps(hours_per_month1[worker], hours_per_month2[worker]))
      end)

    hours_per_year =
      Enum.reduce(@workers, years_per_worker_acc(), fn worker, report ->
        Map.put(report, worker, merge_maps(hours_per_year1[worker], hours_per_year2[worker]))
      end)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map1, map2) do
    Map.merge(map1, map2, fn _key, value1, value2 -> value1 + value2 end)
  end

  defp report_acc do
    all_hours = Enum.into(@workers, %{}, &{&1, 0})
    hours_per_month = months_per_worker_acc()
    hours_per_year = years_per_worker_acc()

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp months_per_worker_acc do
    months = Enum.into(@months, %{}, &{&1, 0})
    Enum.into(@workers, %{}, &{&1, months})
  end

  defp years_per_worker_acc do
    years = Enum.into(@years, %{}, &{&1, 0})
    Enum.into(@workers, %{}, &{&1, years})
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
