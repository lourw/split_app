defmodule SplitApp.Expenses.ExpenseTest do
  use SplitApp.DataCase

  alias SplitApp.Expenses.Expense
  alias SplitApp.AccountsFixtures

  describe "changeset/2" do
    setup do
      user = AccountsFixtures.user_fixture()
      %{user: user}
    end

    test "valid changeset with Money type", %{user: user} do
      attrs = %{
        title: "Dinner",
        description: "Team dinner",
        amount: Money.new(2500, :USD),
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      assert changeset.valid?
      assert changeset.changes.title == "Dinner"
      assert changeset.changes.description == "Team dinner"
      assert changeset.changes.amount == Money.new(2500, :USD)
      assert changeset.changes.created_by_id == user.id
    end

    test "valid changeset without description", %{user: user} do
      attrs = %{
        title: "Coffee",
        amount: Money.new(500, :EUR),
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      assert changeset.valid?
    end

    test "invalid changeset when title is missing", %{user: user} do
      attrs = %{
        description: "Missing title",
        amount: Money.new(1000, :USD),
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).title
    end

    test "invalid changeset when amount is missing", %{user: user} do
      attrs = %{
        title: "Test Expense",
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).amount
    end

    test "invalid changeset when created_by_id is missing" do
      attrs = %{
        title: "Test Expense",
        amount: Money.new(1000, :USD)
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).created_by_id
    end

    test "invalid changeset when amount is zero", %{user: user} do
      attrs = %{
        title: "Zero Amount",
        amount: Money.new(0, :USD),
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      refute changeset.valid?
      assert "amount must be greater than 0" in errors_on(changeset).amount
    end

    test "invalid changeset when amount is negative", %{user: user} do
      attrs = %{
        title: "Negative Amount",
        amount: Money.new(-100, :USD),
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      refute changeset.valid?
      assert "amount must be greater than 0" in errors_on(changeset).amount
    end

    test "invalid changeset when currency is nil", %{user: user} do
      # Create a Money struct with nil currency (this would be an edge case)
      money_with_nil_currency = %Money{amount: 1000, currency: nil}

      attrs = %{
        title: "No Currency",
        amount: money_with_nil_currency,
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      refute changeset.valid?
      assert "currency is required" in errors_on(changeset).amount
    end

    test "invalid changeset when amount is not a Money struct", %{user: user} do
      attrs = %{
        title: "Invalid Money",
        amount: "not_money",
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).amount
    end
  end

  describe "database operations" do
    test "can insert expense with Money type" do
      user = AccountsFixtures.user_fixture()

      attrs = %{
        title: "Database Test",
        description: "Testing database insertion",
        amount: Money.new(1500, :CAD),
        created_by_id: user.id
      }

      changeset = Expense.changeset(%Expense{}, attrs)
      assert {:ok, expense} = Repo.insert(changeset)

      # Verify the expense was saved correctly
      assert expense.title == "Database Test"
      assert expense.description == "Testing database insertion"
      assert expense.amount == Money.new(1500, :CAD)
      assert expense.created_by_id == user.id

      # Verify the Money type is properly stored and retrieved
      assert expense.amount.amount == 1500
      assert expense.amount.currency == :CAD
    end

    test "can query and load expense from database" do
      user = AccountsFixtures.user_fixture()

      # Insert an expense
      changeset =
        Expense.changeset(%Expense{}, %{
          title: "Query Test",
          amount: Money.new(3000, :GBP),
          created_by_id: user.id
        })

      {:ok, inserted_expense} = Repo.insert(changeset)

      # Query it back
      loaded_expense = Repo.get!(Expense, inserted_expense.id)

      # Verify the Money type is properly reconstructed
      assert loaded_expense.amount == Money.new(3000, :GBP)
      assert loaded_expense.amount.amount == 3000
      assert loaded_expense.amount.currency == :GBP
    end
  end
end
