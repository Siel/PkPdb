defmodule Core.Dataset.DB do
  @moduledoc false
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

  # def get(id, :metadata) do
  #   id
  #   |> get_metadata()
  #   |> metadata_to_dataset()
  # end

  def get(id, type) do
    with metadata <- get_metadata(id),
         {:ok, p_metadata, e_k} <- preload_events(metadata, type),
         c_metadata <- clean_metadata(p_metadata),
         {:ok, c_dataset} <- clean_events(c_metadata, type, e_k) do
      try do
        {:ok, struct!(Core.Dataset, c_dataset)}
      rescue
        e in ArgumentError ->
          {:error, e.message}
      end
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def save(%Core.Dataset{} = struct) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_or_update(
      :dataset,
      Metadata.changeset(
        get_metadata(struct.id) || %Metadata{},
        %{
          id: struct.id,
          name: struct.name,
          description: struct.description,
          citation: struct.citation,
          share: struct.share,
          original_type: struct.original_type,
          warnings: struct.warnings,
          owner_id: struct.owner_id
        }
      )
    )
    |> Ecto.Multi.run(:events, fn _, _ ->
      map =
        (struct.events || [])
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
    module = :"Elixir.Core.Dataset.#{String.capitalize(type)}.Event"

    struct(module, %{})
    |> module.changeset(attrs)
    |> Repo.insert()
  end

  defp clean_metadata(metadata) do
    metadata
    |> Map.from_struct()
    |> Map.delete(:__meta__)
    # |> Map.put_new(:events, [])
    |> Map.put_new(:valid?, true)
    |> Map.put_new(:type, nil)
  end

  defp preload_events(metadata, :metadata), do: {:ok, metadata, nil}

  defp preload_events(metadata, type) do
    events_key =
      case type do
        :original ->
          @events_for[metadata.original_type]

        type ->
          @events_for[type]
      end

    cond do
      is_nil(events_key) ->
        {:error, "Type: #{type} has not been implemented"}

      true ->
        {:ok,
         metadata
         |> Core.Repo.preload([events_key]), events_key}
    end
  end

  defp clean_events(metadata, :metadata, _) do
    {:ok,
     metadata
     |> Map.put_new(:events, [])
     |> Map.put_new(:type, nil)
     |> Map.drop(@keys)}
  end

  defp clean_events(metadata, type, events_key) do
    metadata =
      metadata
      |> Map.update!(events_key, fn events ->
        events
        |> Enum.map(fn event ->
          event
          |> Map.from_struct()
          |> Map.delete(:__meta__)
          |> Map.delete(:metadata)
          |> Map.delete(:id)
          |> Map.delete(:updated_at)
          |> Map.delete(:inserted_at)
        end)
      end)
      |> (&Map.put_new(&1, :events, &1[events_key])).()
      |> Map.drop(@keys)
      |> (&Map.put(&1, :type, if(type == :original, do: &1[:original_type], else: type))).()

    {:ok, metadata}
  end

  defp get_metadata(id) do
    Core.Repo.get(Core.Dataset.Metadata, id)
  end
end
