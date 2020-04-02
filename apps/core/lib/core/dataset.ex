defmodule Core.Dataset do
  @moduledoc """
  Dataset API Layer
  A Dataset is an abstraction of a set of events, its fuctionality is to:
  -Model events using a DB
  -Parse events
  -Store events
  -Validate events
  -Transform events from one format to other
  -Render datasets in its own format
  """

  alias Core.Dataset.Metadata
  alias Core.Repo
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
    :events,
    :inserted_at,
    :updated_at
    # :owner,
    # :tags
  ]

  def init() do
    {:ok, ds} =
      %Metadata{}
      |> Metadata.changeset(%{name: "NoName", share: "Free", original_type: "NoType"})
      |> Repo.insert()

    %__MODULE__{
      id: ds.id,
      valid?: false,
      share: ds.share,
      name: ds.name,
      original_type: ds.original_type
    }
  end

  def update_attr!(%__MODULE__{original_type: "NoType", type: nil}, attr)
      when not :erlang.is_map_key(:type, attr) do
    raise("Error in update_attr: :type is required on new Datasets")
  end

  # New dataset with a valid type
  def update_attr!(%__MODULE__{original_type: "NoType"} = dataset, attr) do
    update_attr!(%{dataset | original_type: attr.type}, attr)
  end

  def update_attr!(%__MODULE__{} = dataset, attr) do
    attr =
      attr
      |> Enum.filter(fn
        {k, _v} -> k in [:name, :description, :citation, :share, :type]
      end)
      |> Enum.into(%{})

    Map.merge(dataset, attr)
  end

  def parse_events!(%__MODULE__{type: nil}, _events_str) do
    raise(
      "Error. Cannot parse events if dataset.type is not defined.\nUse Dataset.update_attr/2 to set dataset's type."
    )
  end

  def parse_events!(%__MODULE__{type: type} = dataset, events_str) do
    # TODO: Check for error in parsing
    module = :"Elixir.Core.#{String.capitalize(type)}.Parse"
    %{dataset | events: module.parse_events(events_str)}
  end

  def transform_to(%__MODULE__{} = dataset, target) do
    Core.Dataset.Transform.dataset_to(dataset, target)
  end

  def render(%__MODULE__{type: type} = dataset) do
    apply(Core.Dataset.Render, type |> String.to_atom(), [[dataset: dataset]])
  end

  def save!(%__MODULE__{} = dataset) do
    dataset
    |> validate()
    |> do_save!()
  end

  defp do_save!(%__MODULE__{valid?: valid} = dataset) when valid == true do
    Core.Dataset.DB.save(dataset)
  end

  defp do_save!(_dataset) do
    # TODO: more specific error messages
    raise("Error. The dataset is not valid and will not be saved!")
  end

  defp validate(%__MODULE__{} = dataset) do
    # TODO: Write Validation code.
    %{dataset | valid?: true}
  end
end
