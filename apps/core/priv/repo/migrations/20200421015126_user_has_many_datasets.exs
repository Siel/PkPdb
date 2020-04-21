defmodule Core.Repo.Migrations.UserHasManyDatasets do
  use Ecto.Migration

  def change do
    alter table(:metadata) do
      add :owner_id, references(:users, on_delete: :nilify_all), null: false
    end

    create index(:metadata, [:owner_id])
  end
end
