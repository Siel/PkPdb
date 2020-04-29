defmodule Core.Repo.Migrations.DatasetAndUserHaveManyDownloads do
  use Ecto.Migration

  def change do
    create table(:downloads, primary_key: false) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :metadata_id, references(:metadata, on_delete: :delete_all, type: :binary_id),
        null: false

      add :type, :string

      timestamps(updated_at: false)
    end

    create unique_index(:downloads, [:user_id, :metadata_id, :type])
  end
end
