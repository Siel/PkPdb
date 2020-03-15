defmodule Core.Dataset.Data.Dataset do
  @moduledoc """
  Dataset Data Layer
  """
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "datasets" do
    field :name, :string
    field :description, :string
    field :citation, :string
    field :share, :string
    field :type, :string
    field :original_type, :string
    field :valid, :boolean
    field :warnings, :string

    # events
    # owner
    # tags

    timestamps()
  end
end
