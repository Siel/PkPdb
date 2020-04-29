defmodule Core.Repo.Migrations.UserHasManyDatasets do
  use Ecto.Migration

  def change do
    alter table(:metadata) do
      add :owner_id, references(:users, type: :binary_id, on_delete: :nilify_all), null: false
    end

    create index(:metadata, [:owner_id])
  end
end
