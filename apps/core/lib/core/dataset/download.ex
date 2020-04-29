defmodule Core.Dataset.Download do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Core.Dataset.Metadata
  alias Core.Accounts.User

  @primary_key false
  @foreign_key_type :binary_id
  schema "downloads" do
    field :type, :string
    belongs_to(:metadata, Metadata)
    belongs_to(:user, User)
    timestamps(updated_at: false)
  end

  @doc false
  def changeset(download, attrs) do
    download
    |> cast(attrs, [
      :type,
      :metadata_id,
      :user_id
    ])
    |> validate_required([:type, :metadata_id, :user_id])
    |> unique_constraint(:metadata_id,
      name: "downloads_user_id_metadata_id_type_index",
      message: "this download has already been registered."
    )
  end
end
