defmodule Core.Dataset.Plotter do
  def plot_data(%Core.Dataset{type: type, events: events}) do
    events
    |> Enum.map(&plot_data_mapper(&1, type))
    |> Enum.filter(&(not (&1.out == nil)))
    |> Enum.filter(&(not (&1.out == -99)))
    # |> Enum.sort(&(&1.subject < &2.subject))
    |> Enum.group_by(& &1.subject)
    |> Enum.map(fn {key, val} ->
      {key, Enum.map(val, fn aux -> {aux.time, aux.out} end)}
    end)
  end

  defp plot_data_mapper(event, "pmetrics") do
    %{subject: event.subject, time: event.time, out: event.out}
  end

  defp plot_data_mapper(event, "nonmem") do
    %{subject: event.subject, time: event.time, out: event.dv}
  end
end
