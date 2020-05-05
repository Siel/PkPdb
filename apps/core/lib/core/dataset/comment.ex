defmodule Core.Dataset.Comment do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Dataset.Metadata
  alias Core.Accounts.User

  @primary_key false
  @foreign_key_type :binary_id
  schema "comments" do
    field :content, :string
    belongs_to(:metadata, Metadata)
    belongs_to(:user, User)
    timestamps(updated_at: false)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [
      :content,
      :metadata_id,
      :user_id
    ])
    |> validate_required([:content, :metadata_id, :user_id])
  end
end
