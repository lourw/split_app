defmodule SplitApp.Groups do
  @moduledoc """
  The Groups context.
  """

  import Ecto.Query, warn: false
  alias SplitApp.Repo

  alias SplitApp.Groups.Group
  alias SplitApp.Accounts.User

  @doc """
  Returns the list of groups.

  ## Examples

      iex> list_groups()
      [%Group{}, ...]

  """
  def list_groups do
    Repo.all(Group)
  end

  @doc """
  Gets a single group.

  Raises `Ecto.NoResultsError` if the Group does not exist.

  ## Examples

      iex> get_group!(123)
      %Group{}

      iex> get_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_group!(id), do: Repo.get!(Group, id)

  @doc """
  Creates a group.

  ## Examples

      iex> create_group(%{field: value})
      {:ok, %Group{}}

      iex> create_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_group(attrs \\ %{}) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a group.

  ## Examples

      iex> update_group(group, %{field: new_value})
      {:ok, %Group{}}

      iex> update_group(group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_group(%Group{} = group, attrs) do
    group
    |> Group.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a group.

  ## Examples

      iex> delete_group(group)
      {:ok, %Group{}}

      iex> delete_group(group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_group(%Group{} = group) do
    Repo.delete(group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking group changes.

  ## Examples

      iex> change_group(group)
      %Ecto.Changeset{data: %Group{}}

  """
  def change_group(%Group{} = group, attrs \\ %{}) do
    Group.changeset(group, attrs)
  end

  @doc """
  Returns the list of groups for a given user.

  ## Examples

      iex> list_user_groups(user)
      [%Group{}, ...]

  """
  def list_user_groups(%User{} = user) do
    user
    |> Repo.preload(:groups)
    |> Map.get(:groups)
  end

  @doc """
  Adds a user to a group.

  ## Examples

      iex> add_user_to_group(user, group)
      {:ok, %Group{}}

  """
  def add_user_to_group(%User{} = user, %Group{} = group) do
    group = Repo.preload(group, :users)
    
    group
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:users, [user | group.users])
    |> Repo.update()
  end

  @doc """
  Removes a user from a group.

  ## Examples

      iex> remove_user_from_group(user, group)
      {:ok, %Group{}}

  """
  def remove_user_from_group(%User{} = user, %Group{} = group) do
    group
    |> Repo.preload(:users)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:users, Enum.reject(group.users, &(&1.id == user.id)))
    |> Repo.update()
  end
end
