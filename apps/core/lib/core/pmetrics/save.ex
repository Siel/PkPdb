defmodule Core.Pmetrics.Save do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Pmetrics.Event
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
          |> save_event()
        end)

      {:ok, map}
    end)
    |> Repo.transaction()
  end

  def save_event(attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end
end
