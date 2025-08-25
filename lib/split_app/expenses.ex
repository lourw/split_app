defmodule SplitApp.Expenses do
  @moduledoc """
  The Expenses context.
  """

  import Ecto.Query, warn: false
  alias SplitApp.Repo

  alias SplitApp.Expenses.Expense

  @doc """
  Returns the list of expenses.

  ## Examples

      iex> list_expenses()
      [%Expense{}, ...]

  """
  def list_expenses do
    Repo.all(Expense)
  end

  @doc """
  Returns the list of expenses for a specific user.

  ## Examples

      iex> list_expenses_by_user(123)
      [%Expense{}, ...]

  """
  def list_expenses_by_user(user_id) do
    from(e in Expense,
      where: e.created_by_id == ^user_id,
      order_by: [desc: e.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single expense.

  Raises `Ecto.NoResultsError` if the Expense does not exist.

  ## Examples

      iex> get_expense!(123)
      %Expense{}

      iex> get_expense!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expense!(id), do: Repo.get!(Expense, id)

  @doc """
  Gets a single expense with preloaded associations.

  ## Examples

      iex> get_expense_with_associations!(123)
      %Expense{assigned_users: [...], groups: [...]}

  """
  def get_expense_with_associations!(id) do
    Expense
    |> Repo.get!(id)
    |> Repo.preload([:created_by, :assigned_users, :groups])
  end

  @doc """
  Creates a expense.

  ## Examples

      iex> create_expense(%{field: value})
      {:ok, %Expense{}}

      iex> create_expense(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expense(attrs \\ %{}) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates an expense with associated groups.

  ## Examples

      iex> create_expense_with_groups(%{field: value}, [1, 2])
      {:ok, %Expense{}}

      iex> create_expense_with_groups(%{field: bad_value}, [])
      {:error, %Ecto.Changeset{}}

  """
  def create_expense_with_groups(attrs, group_ids) when is_list(group_ids) do
    Repo.transaction(fn ->
      with {:ok, expense} <- create_expense(attrs) do
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        expense_groups =
          Enum.map(group_ids, fn group_id ->
            %{
              expense_id: expense.id,
              group_id: group_id,
              inserted_at: now,
              updated_at: now
            }
          end)

        if expense_groups != [] do
          {_count, _} = Repo.insert_all("expense_groups", expense_groups)
        end

        get_expense_with_associations!(expense.id)
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a expense.

  ## Examples

      iex> update_expense(expense, %{field: new_value})
      {:ok, %Expense{}}

      iex> update_expense(expense, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates an expense with group associations.

  ## Examples

      iex> update_expense_with_groups(expense, %{field: new_value}, [group1, group2])
      {:ok, %Expense{}}

      iex> update_expense_with_groups(expense, %{field: bad_value}, [])
      {:error, %Ecto.Changeset{}}

  """
  def update_expense_with_groups(%Expense{} = expense, attrs, group_ids)
      when is_list(group_ids) do
    groups = SplitApp.Groups.get_groups_by_ids(group_ids)

    expense
    |> Repo.preload(:groups)
    |> Expense.changeset_with_groups(attrs, groups)
    |> Repo.update()
  end

  @doc """
  Deletes a expense.

  ## Examples

      iex> delete_expense(expense)
      {:ok, %Expense{}}

      iex> delete_expense(expense)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expense(%Expense{} = expense) do
    Repo.delete(expense)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expense changes.

  ## Examples

      iex> change_expense(expense)
      %Ecto.Changeset{data: %Expense{}}

  """
  def change_expense(%Expense{} = expense, attrs \\ %{}) do
    Expense.changeset(expense, attrs)
  end
end
