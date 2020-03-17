defmodule Core.Dataset do
  @moduledoc """
  Dataset API Layer
  A Dataset is an abstraction of a set of events, its fuctionality is to:
  -Parse events
  -Store events
  -Validate events
  -Transform events from one format to other
  """

  alias Core.Dataset.Data
  alias Core.Repo
  alias __MODULE__
  @enforce_keys [:valid?, :share, :name, :original_type, :id]
  defstruct [
    :id,
    :name,
    :description,
    :citation,
    :share,
    :type,
    :original_type,
    :valid?,
    :warnings,
    :errors,
    :inserted_at,
    :updated_at
    # :event,
    # :owner,
    # :tags
  ]

  def init() do
    {:ok, ds} =
      %Data.Dataset{}
      |> Data.Dataset.changeset(%{name: "NoName", share: "Free", original_type: "NoType"})
      |> Repo.insert()

    %__MODULE__{
      id: ds.id,
      valid?: false,
      share: ds.share,
      name: ds.name,
      original_type: ds.original_type
    }
  end

  def update_attr(%__MODULE__{original_type: "NoType", type: nil}, attr)
      when not :erlang.is_map_key(:type, attr) do
    raise("Error in update_attr: :type is required on new Datasets")
  end

  def update_attr(%__MODULE__{} = dataset, attr) do
    attr =
      attr
      |> Enum.filter(fn
        {k, _v} -> k in [:name, :description, :citation, :share, :type]
      end)
      |> Enum.into(%{})

    Map.merge(dataset, attr)
  end

  def parse_events(%Dataset{} = dataset, events_str) do
  end

  def validate() do
  end

  def save() do
  end

  def transform() do
  end
end
