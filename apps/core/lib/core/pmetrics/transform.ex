defmodule Core.Pmetrics.Transform do
  alias Core.Pmetrics

  def to(%Core.Dataset{type: "pmetrics"} = dataset, "nonmem" = target) do
    # if any of the elements in the ID(subject) column is non numeric
    # then all the ID should be replaced with an autoincremental numeric ID
    # Transformations at dataset level
    dataset =
      dataset
      |> translate_dataset_ids()

    # Transformations at event level
    events =
      dataset.events
      |> Enum.with_index()
      |> Enum.map(fn {event, index} -> event_to({event, index}, target) end)

    %{
      dataset
      | events: events,
        type: target,
        valid?: false
    }
  end

  defp event_to({event, index}, "nonmem" = _format) do
    IO.inspect(event.evid)
    IO.inspect(event.dose)
    IO.inspect(event.dur)
    IO.inspect(event.out)

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
      addl: event.addl,
      ii: event.ii,
      cov: event.cov
    }
    |> Enum.map(fn {k, v} ->
      if is_tuple(v) do
        {val, _w} = v
        {k, val}
      else
        {k, v}
      end
    end)
    |> Enum.into(%{})

    # %{result: result, warnings: _warnings} =
    #   %{event: event, index: index}
    #   |> translate(:subject, to: format)
    #   |> translate

    # result
  end

  defp event_to(%Pmetrics.Event{}, _) do
    raise "Error. Unimplemented transformation"
  end

  # defp translate(%{event: event, index: index} = map, key, to: format)
  #      when not :erlang.is_map_key(:result, map) and
  #             not :erlang.is_map_key(:warnings, map) do
  #   translate(%{event: event, index: index, result: %{}, warnings: []}, key, to: format)
  # end

  # defp translate(map, :subject, to: "nonmem") do
  #   %{
  #     map
  #     | result:
  #         Map.put_new(map.result, :subject, map.event.subject |> Core.Pmetrics.Parse.type(:int))
  #   }
  # end

  defp translate_dataset_ids(dataset) do
    replace? =
      dataset.events
      |> Enum.all?(fn event -> String.match?(event.subject, ~r/^[0-9]+$/) end)
      |> Kernel.not()

    do_calc_ids(replace?, dataset)
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

    dataset =
      dataset
      |> add_warning("All the IDS have been replaced to autoincremental numbers")

    %{dataset | events: events}
  end

  defp do_calc_ids(false, dataset) do
    dataset
  end

  defp add_warning(%Core.Dataset{} = dataset, warning) do
    warnings = dataset.warnings || []

    %{dataset | warnings: [warning | warnings]}
  end
end
