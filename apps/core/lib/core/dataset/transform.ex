defmodule Core.Dataset.Transform do
  @moduledoc false
  def dataset_to(%Core.Dataset{type: type} = dataset, target) do
    transform = :"Elixir.Core.Dataset.#{String.capitalize(type)}.Transform"

    # Transformations in a general level
    dataset =
      dataset
      |> transform.set_to(target)

    # Transformations at event level
    evs_warns =
      dataset.events
      |> Enum.with_index()
      |> Enum.map(fn {event, index} ->
        {event, index}
        |> transform.event_to(target)
        |> extract_warnings()
      end)
      |> Enum.reduce(%{events: [], warnings: []}, fn ew, acc ->
        %{acc | events: [ew.event | acc.events], warnings: [ew.warnings | acc.warnings]}
      end)
      |> Map.update!(:events, fn events -> events |> Enum.reverse() end)
      |> Map.update!(:warnings, fn warnings -> warnings |> Enum.reverse() |> List.flatten() end)
      # TODO: is possible to have previous warnings
      |> Map.update!(:warnings, fn warnings -> %{"T-f:#{type}-t:#{target}" => warnings} end)

    %{
      dataset
      | events: evs_warns.events,
        type: target,
        valid?: false,
        warnings: evs_warns.warnings
    }
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
end
