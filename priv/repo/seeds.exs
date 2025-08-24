# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SplitApp.Repo.insert!(%SplitApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias SplitApp.Accounts
alias SplitApp.Groups

# Create test users
{:ok, user1} = Accounts.register_user(%{
  email: "user1@example.com",
  password: "password12345"
})

{:ok, user2} = Accounts.register_user(%{
  email: "user2@example.com", 
  password: "password12345"
})

# Create test groups
{:ok, group1} = Groups.create_group(%{
  name: "Weekend Trip",
  description: "Expenses for our weekend getaway"
})

{:ok, group2} = Groups.create_group(%{
  name: "Monthly Groceries",
  description: "Shared grocery expenses for the apartment"
})

{:ok, group3} = Groups.create_group(%{
  name: "Birthday Party",
  description: "Planning and expenses for Sarah's birthday"
})

# Add users to groups
Groups.add_user_to_group(user1, group1)
Groups.add_user_to_group(user1, group2)
Groups.add_user_to_group(user2, group1)
Groups.add_user_to_group(user2, group3)

IO.puts("Seed data created successfully!")
IO.puts("Test users:")
IO.puts("  - user1@example.com (password: password12345)")
IO.puts("  - user2@example.com (password: password12345)")
