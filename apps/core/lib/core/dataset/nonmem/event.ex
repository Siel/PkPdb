defmodule Core.Dataset.Nonmem.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Dataset.Metadata

  # alias Core.Dataset.Metadata

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "nm_events" do
    # NONMEM's ID was changed to subject
    field :subject, :integer
    field :time, :float
    # This is because they can use "." as a placeholder
    field :amt, :string
    # The same reason
    field :dv, :string
    field :rate, :float
    field :mdv, :integer
    field :evid, :integer
    field :cmt, :integer
    field :ss, :integer
    field :addl, :integer
    field :ii, :float
    field :cov, :map

    belongs_to(:metadata, Metadata)

    timestamps()
  end

  @doc """
  Validate NONMEM requirements as stated on the NONMEM tutorial
  https://ascpt.onlinelibrary.wiley.com/doi/pdf/10.1002/psp4.12404
  """
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :subject,
      :time,
      :amt,
      :dv,
      :rate,
      :mdv,
      :evid,
      :cmt,
      :ss,
      :addl,
      :ii,
      :cov,
      :metadata_id
    ])
    # TODO: revisar esto
    |> validate_required([:subject, :time, :amt])
    |> unique_constraint(:metadata_id, name: :nmevents_metadata_metadata_id_nmevent_id_index)
    |> validate_required(:metadata_id)
    |> nm_validation()
  end

  defp nm_validation(changeset) do
    changeset
    |> validate_str_number_or_dot(:amt)
    |> validate_str_number_or_dot(:dv)
    |> validate_number(:rate, greater_than_or_equal_to: 0)
    |> validate_inclusion(:mdv, [0, 1])
    |> validate_inclusion(:evid, 0..4)
    |> validate_inclusion(:ss, [0, 1])
  end

  def validate_str_number_or_dot(changeset, key) do
    case get_field(changeset, key)
         |> String.match?(~r/^([+]?\d*(([.]\d{3})+)?([.]\d+)?([eE][+-]?\d+)?|.)$/) do
      true ->
        changeset

      false ->
        add_error(changeset, key, "Error. ${key} must be numerical or '.' ")
    end
  end
end
