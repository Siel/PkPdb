defmodule Core.Dataset.DB do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Dataset.Metadata

  @events_for %{
    "pmetrics" => :pm_events,
    "nonmem" => :nm_events
  }

  def get(id) do
    dataset = get_metadata(id)

    data =
      dataset
      |> Core.Repo.preload([@events_for[dataset.original_type]])
      |> Map.from_struct()
      |> Map.update!(@events_for[dataset.original_type], fn events ->
        events
        |> Enum.map(fn event -> Map.from_struct(event) end)
      end)
      |> Map.delete(:__meta__)
      |> (&Map.put_new(&1, :events, &1[@events_for[dataset.original_type]])).()
      |> Map.delete(@events_for[dataset.original_type])
      |> (&Map.put_new(&1, :valid?, true)).()
      |> (&Map.put(&1, :type, &1[:original_type])).()

    struct!(Core.Dataset, data)
  end

  def save(%Core.Dataset{} = struct) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :dataset,
      Metadata.changeset(
        get_metadata(struct.id),
        %{
          name: struct.name,
          description: struct.description,
          citation: struct.citation,
          share: struct.share,
          original_type: struct.original_type,
          warnings: struct.warnings
        }
      )
    )
    |> Ecto.Multi.run(:events, fn _, _ ->
      map =
        struct.events
        |> Enum.map(fn event ->
          event
          |> Map.put(:metadata_id, struct.id)
          |> save_event(struct.type)
        end)

      {:ok, map}
    end)
    |> Repo.transaction()
  end

  defp save_event(attrs, type) do
    module = :"Elixir.Core.#{String.capitalize(type)}.Event"

    struct(module, %{})
    |> module.changeset(attrs)
    |> Repo.insert()
  end

  defp get_metadata(id) do
    Core.Repo.get(Core.Dataset.Metadata, id)
  end
end
