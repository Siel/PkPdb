defmodule Core.Repo.Migrations.MetadataHasManyEvents do
  use Ecto.Migration

  def change do
    alter table(:pm_events) do
      add :metadata_id, references(:metadata, on_delete: :delete_all, type: :binary_id)
    end

    create index(:pm_events, [:metadata_id])
  end
end
