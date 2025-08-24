defmodule SplitApp.GroupsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SplitApp.Groups` context.
  """

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> SplitApp.Groups.create_group()

    group
  end

  @doc """
  Generate a group and add a user to it.
  """
  def group_fixture_with_user(user, attrs \\ %{}) do
    group = group_fixture(attrs)
    {:ok, group} = SplitApp.Groups.add_user_to_group(user, group)
    group
  end
end
