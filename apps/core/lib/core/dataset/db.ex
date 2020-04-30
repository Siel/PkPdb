defmodule Core.Dataset.DB do
  @moduledoc false
  import Ecto.Query, warn: false
  alias Core.Repo
  alias Core.Dataset.{Metadata, Download}

  @events_for %{
    "pmetrics" => :pm_events,
    "nonmem" => :nm_events
  }

  @supported_types @events_for |> Map.keys()

  @keys @events_for
        |> Map.keys()
        |> Enum.map(fn key -> @events_for[key] end)

  @doc false
  def get(id, type) do
    with {:ok, metadata} <- get_metadata(id),
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

  @doc false
  def save(%Core.Dataset{} = struct) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert_or_update(
      :dataset,
      Metadata.changeset(
        case get_metadata(struct.id) do
          {:ok, metadata} ->
            metadata

          {:error, _reason} ->
            %Metadata{}
        end,
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

  @doc false
  def is_transformed_to(%Core.Dataset{} = dataset, type) when type in @supported_types do
    # TODO
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

  @doc false
  def get_metadata(id) do
    try do
      case Core.Repo.get(Core.Dataset.Metadata, id) do
        nil ->
          {:error, "Dataset not found"}

        metadata ->
          {:ok, metadata}
      end
    rescue
      e in ArgumentError ->
        {:error, e.message}
    end
  end

  @doc false
  def register_download(%Core.Dataset{} = dataset, type, user_id) do
    %Download{}
    |> Download.changeset(%{type: type, metadata_id: dataset.id, user_id: user_id})
    |> Repo.insert()
  end

  @doc false
  def get_downloads(%Core.Dataset{} = dataset) do
    from(
      d in Download,
      where: d.metadata_id == ^dataset.id,
      join: u in assoc(d, :user),
      select: %{
        user_name: u.name,
        user_last_name: u.last_name,
        date: d.inserted_at,
        type: d.type
      }
    )
    |> Repo.all()
  end
end
