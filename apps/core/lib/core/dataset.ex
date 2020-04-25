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
  -Provide search functionality
  -Calculate the required data to graph.
  """

  @enforce_keys [:valid?, :id]
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
    :updated_at,
    :owner_id,
    :owner
    # :tags
  ]

  @supported_types ["nonmem", "pmetrics"]

  def init!(type) when type in @supported_types do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      valid?: false,
      original_type: type,
      type: type
    }
  end

  def update_metadata!(%__MODULE__{} = dataset, metadata) do
    metadata =
      metadata
      |> Enum.filter(fn
        {k, _v} -> k in [:name, :description, :citation, :share, :warnings, :owner_id]
      end)
      |> Enum.into(%{})

    Map.merge(dataset, metadata)
  end

  def parse_events!(%__MODULE__{type: type} = dataset, events_str) do
    # TODO: Check for error in parsing
    module = :"Elixir.Core.Dataset.#{String.capitalize(type)}.Parse"
    %{dataset | events: module.parse_events(events_str)}
  end

  def transform_to(%__MODULE__{} = dataset, target) when target in @supported_types do
    Core.Dataset.Transform.dataset_to(dataset, target)
  end

  def render(%__MODULE__{type: type} = dataset) do
    apply(Core.Dataset.Render, type |> String.to_atom(), [[dataset: dataset]])
  end

  def plot_data(%Core.Dataset{type: "pmetrics", events: events}) do
    events
    |> Enum.map(fn event -> %{subject: event.subject, time: event.time, out: event.out} end)
    |> Enum.filter(&(not (&1.out == nil)))
    |> Enum.filter(&(not (&1.out == -99)))
    # |> Enum.sort(&(&1.subject < &2.subject))
    |> Enum.group_by(& &1.subject)
    |> Enum.map(fn {key, val} ->
      {key, Enum.map(val, fn aux -> {aux.time, aux.out} end)}
    end)
  end

  def plot_data(%Core.Dataset{type: type}) do
    raise(ArgumentError, "plot_data\1 not implemented for type #{type}")
  end

  def search(query) when is_bitstring(query) do
    Core.Dataset.Search.do_search(query)
  end

  def save(%__MODULE__{} = dataset) do
    dataset
    |> validate()
    |> do_save()
  end

  def get(id, type \\ :original) do
    Core.Dataset.DB.get(id, type)
  end

  defp do_save(%__MODULE__{valid?: valid} = dataset) when valid do
    Core.Dataset.DB.save(dataset)
  end

  defp do_save(_dataset) do
    # TODO: more specific error messages
    raise("Error. The dataset is not valid and will not be saved!")
  end

  defp validate(%__MODULE__{} = dataset) do
    # TODO: Write Validation code.
    %{dataset | valid?: true}
  end
end
