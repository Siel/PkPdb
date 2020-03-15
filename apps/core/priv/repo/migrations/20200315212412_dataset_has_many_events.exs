defmodule Core.Repo.Migrations.DatasetHasManyEvents do
  use Ecto.Migration

  def change do
    alter table(:pm_events) do
      add :dataset_id, references(:datasets, on_delete: :delete_all, type: :binary_id)
    end

    create index(:pm_events, [:dataset_id])
  end
end
