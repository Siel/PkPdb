defmodule Core.Dataset.Data.PMEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :subject,
    :evid,
    :time,
    :dur,
    :dose,
    :addl,
    :ii,
    :input,
    :outeq,
    :out,
    :c0,
    :c1,
    :c2,
    :c3,
    :dataset_id
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pm_events" do
    field(:dose, :float)
    field(:dur, :float)
    field(:evid, :integer)
    field(:subject, :string)
    field(:time, :float)
    field(:addl, :integer)
    field(:ii, :float)
    field(:input, :integer)
    field(:out, :float)
    field(:outeq, :integer)
    field(:c0, :float)
    field(:c1, :float)
    field(:c2, :float)
    field(:c3, :float)
    belongs_to(:dataset, Dataset)

    timestamps()
  end

  @doc """
  Validate Pmetrics requirements as stated on the pmetrics manual

  All the fields are required
  Subject must have between 1 and 11 characters
  EVID only only can be "0", "1" or "4"
  """
  def changeset(event, attrs) do
    event
    |> cast(attrs, @fields)
    |> pm_validation()
  end

  defp pm_validation(changeset) do
    changeset
    |> validate_required(@fields)
    |> validate_length(:subject, min: 1)
    |> validate_length(:subject, max: 11)
    |> validate_pm_evid()
  end

  defp validate_pm_evid(changeset) do
    changeset
    |> validate_pm_evid(get_field(changeset, :evid))
  end

  defp validate_pm_evid(changeset, evid) when evid in [0, 1, 4], do: changeset

  defp validate_pm_evid(changeset, _evid) do
    add_error(changeset, :evid, "Evid must be '0', '1', or '4'")
  end
end
