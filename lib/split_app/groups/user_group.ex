defmodule SplitApp.Groups.UserGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "user_groups" do
    belongs_to :user, SplitApp.Accounts.User, primary_key: true
    belongs_to :group, SplitApp.Groups.Group, primary_key: true

    timestamps(type: :utc_datetime)
  end

  def changeset(user_group, attrs) do
    user_group
    |> cast(attrs, [:user_id, :group_id])
    |> validate_required([:user_id, :group_id])
    |> unique_constraint([:user_id, :group_id])
  end
end
