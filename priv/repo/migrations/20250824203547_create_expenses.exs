defmodule SplitApp.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :title, :string, null: false
      add :description, :text
      add :amount, :map, null: false
      add :created_by_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:expenses, [:created_by_id])

    create table(:expense_assignments) do
      add :expense_id, references(:expenses, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:expense_assignments, [:expense_id, :user_id])

    create table(:expense_groups) do
      add :expense_id, references(:expenses, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:expense_groups, [:expense_id, :group_id])
  end
end
