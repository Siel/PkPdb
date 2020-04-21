defmodule Core.Dataset.Metadata do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Dataset.{Pmetrics, Nonmem}

  @primary_key {:id, :binary_id, autogenerate: false}
  # @foreign_key_type :binary_id
  schema "metadata" do
    field :name, :string
    field :description, :string
    field :citation, :string
    field :share, :string
    field :original_type, :string
    field :warnings, :map
    field :errors, :map
    has_many(:pm_events, Pmetrics.Event)
    has_many(:nm_events, Nonmem.Event)
    belongs_to(:owner, Core.Accounts.User)

    # events
    # owner
    # tags

    timestamps()
  end

  @doc false
  def changeset(dataset, attrs) do
    dataset
    |> cast(attrs, [
      :id,
      :name,
      :description,
      :citation,
      :share,
      :original_type,
      :warnings,
      :errors,
      :owner_id
    ])
    |> validate_required([:name, :share, :original_type, :owner_id])
  end
end
