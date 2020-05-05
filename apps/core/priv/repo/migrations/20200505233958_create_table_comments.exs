defmodule Core.Repo.Migrations.CreateTableComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :user_id, references(:users, type: :binary_id, on_delete: :nilify_all), null: false

      add :metadata_id, references(:metadata, on_delete: :delete_all, type: :binary_id),
        null: false

      add :content, :text, null: false

      timestamps(updated_at: false)
    end
  end
end
