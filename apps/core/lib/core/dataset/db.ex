defmodule Core.Dataset.DB do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Dataset.Metadata

  def save_dataset(%Core.Dataset{} = struct) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(
      :dataset,
      Metadata.changeset(
        Metadata.get(struct.id),
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

  def get_dataset(id, _type \\ "pmetrics") do
    data =
      id
      |> Core.Dataset.Metadata.get()
      |> Map.from_struct()
      # TODO: VOLVER ESTO INDEPENDIENTE DE PMETRICS ASAP!!!!
      |> Map.update!(:pm_events, fn events ->
        events
        |> Enum.map(fn event -> Map.from_struct(event) end)
      end)
      |> Map.delete(:__meta__)
      |> (&Map.put_new(&1, :events, &1[:pm_events])).()
      |> Map.delete(:pm_events)
      |> (&Map.put_new(&1, :valid?, true)).()
      |> (&Map.put(&1, :type, &1[:original_type])).()

    struct!(Core.Dataset, data)
  end

  defp save_event(attrs, type) do
    module = :"Elixir.Core.#{String.capitalize(type)}.Event"

    struct(module, %{})
    |> module.changeset(attrs)
    |> Repo.insert()
  end
end
