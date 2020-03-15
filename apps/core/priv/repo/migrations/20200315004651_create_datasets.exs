defmodule Core.Repo.Migrations.CreateDatasets do
  use Ecto.Migration

  def change do
    create table(:datasets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :text
      add :citation, :text
      add :share, :string
      # add :type, :string
      add :original_type, :string
      # add :valid, :bool
      add :warnings, :map
      add :errors, :map

      # events
      # owner
      # tags

      timestamps()
    end
  end
end
