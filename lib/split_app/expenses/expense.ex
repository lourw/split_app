defmodule SplitApp.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  schema "expenses" do
    field :title, :string
    field :description, :string
    field :amount, Money.Ecto.Map.Type

    belongs_to :created_by, SplitApp.Accounts.User, foreign_key: :created_by_id
    many_to_many :assigned_users, SplitApp.Accounts.User, join_through: "expense_assignments"
    many_to_many :groups, SplitApp.Groups.Group, join_through: "expense_groups"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:title, :description, :amount, :created_by_id])
    |> validate_required([:title, :amount, :created_by_id])
    |> validate_money(:amount)
  end

  defp validate_money(changeset, field) do
    validate_change(changeset, field, fn
      _, %Money{amount: amount, currency: currency} when amount > 0 and not is_nil(currency) -> []
      _, %Money{amount: amount} when amount <= 0 -> [{field, "amount must be greater than 0"}]
      _, %Money{currency: nil} -> [{field, "currency is required"}]
      _, _ -> [{field, "must be a valid money amount"}]
    end)
  end
end
