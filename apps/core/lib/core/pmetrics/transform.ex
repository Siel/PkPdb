defmodule Core.Pmetrics.Transform do
  @moduledoc false

  def event_set_to(dataset, "nonmem") do
    replace? =
      dataset.events
      |> Enum.all?(fn event -> String.match?(event.subject, ~r/^[0-9]+$/) end)
      |> Kernel.not()

    do_calc_ids(replace?, dataset)
  end

  def event_to({event, index}, "nonmem") do
    calc_rate = fn event ->
      if event.evid == 1 do
        if(event.dur == 0, do: 0, else: event.dose / event.dur)
      else
        nil
      end
    end

    calc_cmt = fn event, index ->
      if event.evid == 0 do
        {event.outeq, "W-Line#{index}: cmt set to pmetrics' outeq, this might not be correct"}
      end

      if event.evid in [1, 4] do
        {event.input, "W-Line#{index}: cmt set to pmetrics' input, this might not be correct"}
      end
    end

    %{
      subject: event.subject |> Core.Pmetrics.Parse.type(:int),
      time: event.time,
      dv: if(event.out == -99 or is_nil(event.out), do: ".", else: "#{event.out}"),
      rate: calc_rate.(event),
      mdv: if(event.evid == 0 and (event.out == -99 or is_nil(event.out)), do: 1, else: 0),
      cmt: calc_cmt.(event, index),
      ss: if(event.addl == -1, do: 1, else: 0),
      addl: if(event.addl == -1, do: 0, else: event.addl),
      ii: event.ii,
      cov: event.cov
    }
    |> extract_warnings()
  end

  defp extract_warnings(event) do
    event
    |> Enum.reduce(%{event: %{}, warnings: []}, fn {k, v}, acc ->
      if is_tuple(v) do
        {val, w} = v
        %{acc | event: Map.put_new(acc.event, k, val), warnings: [w | acc.warnings]}
      else
        %{acc | event: Map.put_new(acc.event, k, v), warnings: acc.warnings}
      end
    end)
  end

  defp do_calc_ids(true, dataset) do
    dict =
      dataset
      |> Enum.reduce([], fn %{subject: subject}, acc ->
        if subject not in acc, do: [subject | acc], else: acc
      end)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.into(%{})

    events =
      dataset.events
      |> Enum.map(&Map.update!(&1, :subject, fn subject -> dict[subject] end))

    warnings = dataset.warnings || []

    %{
      dataset
      | events: events,
        warnings: ["All the IDS have been replaced to autoincremental numbers" | warnings]
    }
  end

  defp do_calc_ids(false, dataset) do
    dataset
  end
end
