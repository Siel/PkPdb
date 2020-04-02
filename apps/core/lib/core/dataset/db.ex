defmodule Core.Dataset.DB do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Dataset.Metadata

  @events_for %{
    "pmetrics" => :pm_events,
    "nonmem" => :nm_events
  }

  @keys @events_for
        |> Map.keys()
        |> Enum.map(fn key -> @events_for[key] end)

  def get(id, type) do
    dataset = get_metadata(id)

    events_key =
      case type do
        :original ->
          @events_for[dataset.original_type]

        type ->
          if type in Map.keys(@events_for) do
            @events_for[type]
          else
            raise("Core.Dataset.get with type: #{type} has not been implemented")
          end
      end

    data =
      dataset
      |> Core.Repo.preload([events_key])
      |> Map.from_struct()
      |> Map.update!(events_key, fn events ->
        events
        |> Enum.map(fn event -> Map.from_struct(event) end)
      end)
      |> Map.delete(:__meta__)
      |> (&Map.put_new(&1, :events, &1[events_key])).()
      |> Map.drop(@keys)
      |> (&Map.put_new(&1, :valid?, true)).()
      |> (&Map.put(&1, :type, if(type == :original, do: &1[:original_type], else: type))).()

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
