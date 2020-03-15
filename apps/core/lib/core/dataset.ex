defmodule Core.Dataset do
  @moduledoc """
  Dataset API Layer
  A Dataset is an abstraction of a set of events, its fuctionality is to:
  -Decode events
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
    :inserted_at,
    :updated_at
    # :event,
    # :owner,
    # :tags
  ]

  def dummy_dataset() do
    {:ok, ds} =
      %Data.Dataset{}
      |> Data.Dataset.changeset(%{
        name: "dummy",
        share: "free",
        original_type: "dummy"
      })
      |> Repo.insert()

    %__MODULE__{
      id: ds.id,
      valid?: false,
      share: ds.share,
      name: ds.name,
      original_type: ds.original_type
    }
  end
end
