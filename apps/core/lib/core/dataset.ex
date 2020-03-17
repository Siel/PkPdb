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
    # :event,
    # :owner,
    # :tags
  ]

  @parseModules %{
    "pmetrics" => Core.Dataset.Parse.Pmetrics
  }
  @saveModules %{
    "pmetrics" => Core.Dataset.Data.PMEvent
  }

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

  def update_attr!(%__MODULE__{original_type: "NoType", type: nil}, attr)
      when not :erlang.is_map_key(:type, attr) do
    raise("Error in update_attr: :type is required on new Datasets")
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

  def parse_events!(%__MODULE__{} = dataset, events_str) do
    # TODO: Check for error in parsing
    %{dataset | events: apply(@parseModules[dataset.type], :parse_events, [events_str])}
  end

  def validate(%__MODULE__{} = dataset) do
    # TODO: Write Validation code.
    %{dataset | valid?: true}
  end

  def save!(%__MODULE__{valid?: true} = dataset) do
    apply(@saveModules[dataset.type], :save_dataset, [dataset])
  end

  def save!(_dataset) do
    # TODO: more specific error messages
    raise("Error. The dataset is not valid and will not be saved!")
  end

  def transform() do
  end
end
