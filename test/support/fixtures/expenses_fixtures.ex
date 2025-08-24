defmodule SplitApp.ExpensesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SplitApp.Expenses` context.
  """

  alias SplitApp.AccountsFixtures

  def valid_expense_attributes(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    Enum.into(attrs, %{
      title: "Test Expense",
      description: "Test expense description",
      amount: Money.new(1000, :USD),
      created_by_id: user.id
    })
  end

  def expense_fixture(attrs \\ %{}) do
    attrs
    |> valid_expense_attributes()
    |> SplitApp.Expenses.Expense.changeset(%SplitApp.Expenses.Expense{})
    |> SplitApp.Repo.insert!()
  end
end
