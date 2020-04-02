defmodule Core.Repo.Migrations.MetadataHasManyNMEvents do
  use Ecto.Migration

  def change do
    alter table(:nm_events) do
      add :metadata_id, references(:metadata, on_delete: :delete_all, type: :binary_id)
    end

    create index(:nm_events, [:metadata_id])
  end
end
