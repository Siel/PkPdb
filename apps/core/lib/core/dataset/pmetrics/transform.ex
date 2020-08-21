defmodule Core.Dataset.Pmetrics.Transform do
  @moduledoc false

  def set_to(%Core.Dataset{events: events} = dataset, "nonmem") do
    replace? =
      events
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

    calc_evid = fn evid ->
      if evid in [0, 1, 4],
        do: evid,
        else: {nil, "W-Line#{index}: evid = #{evid} not supported, set to '.'"}
    end

    IO.inspect(event)

    %{
      subject: event.subject |> Core.Dataset.ParseHelpers.type(:int),
      time: event.time,
      amt: if(is_nil(event.dose), do: nil, else: event.dose),
      dv: if(event.out == -99 or is_nil(event.out), do: nil, else: event.out),
      rate: calc_rate.(event),
      mdv: if(event.evid == 0 and (event.out == -99 or is_nil(event.out)), do: 1, else: 0),
      evid: calc_evid.(event.evid),
      cmt: calc_cmt.(event, index),
      ss: if(event.addl == -1, do: 1, else: 0),
      addl: if(event.addl == -1, do: 0, else: event.addl),
      ii: event.ii,
      cov: event.cov
    }
  end

  defp do_calc_ids(true, dataset) do
    dict =
      dataset.events
      |> Enum.reduce([], fn %{subject: subject}, acc ->
        if subject not in acc, do: [subject | acc], else: acc
      end)
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.into(%{})

    events =
      dataset.events
      |> Enum.map(&Map.update!(&1, :subject, fn subject -> "#{dict[subject]}" end))

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
