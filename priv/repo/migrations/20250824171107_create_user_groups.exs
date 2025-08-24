defmodule SplitApp.Repo.Migrations.CreateUserGroups do
  use Ecto.Migration

  def change do
    create table(:user_groups, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      
      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_groups, [:user_id, :group_id])
    create index(:user_groups, [:user_id])
    create index(:user_groups, [:group_id])
  end
end
