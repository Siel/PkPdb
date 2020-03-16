defmodule Core.Dataset.Data.PMEvent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Core.Dataset.Data

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pm_events" do
    field :dose, :float
    field :dur, :float
    field :evid, :integer
    field :subject, :string
    field :time, :float
    field :addl, :integer
    field :ii, :float
    field :input, :integer
    field :out, :float
    field :outeq, :integer
    field :c0, :float
    field :c1, :float
    field :c2, :float
    field :c3, :float
    field :cov, :map

    belongs_to(:dataset, Data.Dataset)

    timestamps()
  end

  @doc """
  Validate Pmetrics requirements as stated on the pmetrics manual

  Subject must have between 1 and 11 characters
  EVID only only can be "0", "1" or "4"
  if EVID == 1 DUR and DOSE are required
  if EVID == 1 ADDL and II are optional
  if EVID == 0 OUT is required
  time is always required
  subject is always required
  check c0, c1, c2, c3
  """
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
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
      :dataset_id,
      :cov
    ])
    |> unique_constraint(:dataset_id, name: :pmevents_datasets_dataset_id_pmevent_id_index)
    |> validate_required(:dataset_id)
    |> pm_validation()
  end

  def pm_validation(changeset) do
    changeset
    |> validate_pm_subject
    |> validate_pm_evid()
    |> validate_pm_evid_req_key(:dur)
    |> validate_pm_evid_req_key(:dose)
    |> validate_pm_out()
  end

  defp validate_pm_out(changeset) do
    case get_field(changeset, :evid) do
      0 ->
        validate_required(changeset, [:out])

      _ ->
        changeset
    end
  end

  defp validate_pm_evid_req_key(changeset, key) do
    case get_field(changeset, :evid) do
      1 ->
        validate_required(changeset, [key])

      _ ->
        changeset
    end
  end

  defp validate_pm_subject(changeset) do
    changeset
    |> validate_length(:subject, min: 1)
    |> validate_length(:subject, max: 11)
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
