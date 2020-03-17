defmodule Core.Dataset.Data.Pmetrics do
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Dataset.Data.PMEvent, as: Event
  alias Core.Dataset.Data.Dataset

  def save_dataset(%Core.Dataset{} = struct) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_or_update(
      :dataset,
      Dataset.changeset(
        Dataset.get(struct.id),
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
    |> Ecto.Multi.run(:events, fn a, b ->
      IO.inspect("epa")
      IO.inspect(a)
      IO.inspect(b)

      map =
        struct.events
        |> Enum.map(fn event ->
          event
          |> Map.put(:dataset_id, struct.id)
          |> save_event()
        end)

      {:ok, map}
    end)
    |> Repo.transaction()
  end

  defp save_event(attrs) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end
end
