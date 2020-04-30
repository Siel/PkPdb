defmodule Core.Repo.Migrations.AddSupportedTypesToMetadata do
  use Ecto.Migration

  def change do
    alter table(:metadata) do
      add :implemented_types, {:array, :string}, default: []
    end
  end
end
