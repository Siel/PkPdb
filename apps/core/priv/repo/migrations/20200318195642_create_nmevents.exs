defmodule Core.Repo.Migrations.CreateNmevents do
  use Ecto.Migration

  def change do
    create table(:nm_events, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      # NONMEM's ID was changed to subject
      add(:subject, :integer, null: false)
      add(:time, :float, null: false)
      # This is because they can use "." as a placeholder
      add(:amt, :string, null: false)
      # The same reason
      add(:dv, :string, null: false)
      add(:rate, :float)
      add(:mdv, :integer)
      add(:evid, :integer)
      add(:cmt, :integer)
      add(:ss, :integer)
      add(:addl, :integer)
      add(:ii, :float)
      add(:cov, :map)

      timestamps()
    end
  end
end
