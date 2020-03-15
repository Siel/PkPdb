defmodule Core.Dataset.Data.Dataset do
  @moduledoc """
  Dataset Data Layer
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Dataset.Data

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "datasets" do
    field :name, :string
    field :description, :string
    field :citation, :string
    field :share, :string
    field :original_type, :string
    field :warnings, :map
    field :errors, :map
    has_many(:PM_events, Data.PMEvent)

    # events
    # owner
    # tags

    timestamps()
  end

  @doc false
  def changeset(dataset, attrs) do
    dataset
    |> cast(attrs, [
      :name,
      :description,
      :citation,
      :share,
      :original_type,
      :warnings,
      :errors
    ])
    |> validate_required([:name, :share, :original_type])
  end
end
