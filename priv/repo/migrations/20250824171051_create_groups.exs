defmodule SplitApp.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
