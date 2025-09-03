defmodule SplitAppWeb.DashboardLiveTest do
  use SplitAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import SplitApp.ExpensesFixtures
  import SplitApp.GroupsFixtures

  @create_expense_attrs %{
    description: "Test expense from dashboard",
    title: "Dashboard Expense",
    amount_display: "35.50",
    currency: "USD"
  }

  describe "Dashboard" do
    setup [:register_and_log_in_user]

    test "displays welcome message and dashboard sections", %{conn: conn, user: user} do
      {:ok, _live, html} = live(conn, ~p"/dashboard")

      assert html =~ "Welcome, #{user.email}!"
      assert html =~ "Recent Expenses"
      assert html =~ "Your Groups"
      assert html =~ "Add New Expense"
      assert html =~ "Create New Group"
    end

    test "opens expense modal when clicking Add New Expense", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dashboard")

      # Click the "Add New Expense" button
      assert live
             |> element("button", "Add New Expense")
             |> render_click()

      # Verify modal is shown
      assert has_element?(live, "#expense-modal")
      assert render(live) =~ "New Expense"
    end

    test "creates expense through modal and updates dashboard", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dashboard")

      # Initially no expenses
      assert render(live) =~ "No expenses yet"

      # Open modal
      live
      |> element("button", "Add New Expense")
      |> render_click()

      # Fill and submit form
      assert live
             |> form("#expense-form", expense: @create_expense_attrs)
             |> render_submit()

      # Wait for the update
      :timer.sleep(100)
      
      # Verify we're still on the dashboard (not redirected)
      html = render(live)
      assert html =~ "Welcome"
      
      # Verify expense was created and shows in recent expenses
      assert html =~ "Dashboard Expense"
      assert html =~ "Test expense from dashboard"
      
      # Verify modal is closed
      refute has_element?(live, "#expense-modal")
      
      # Verify flash message
      assert html =~ "Expense created successfully"
    end

    test "closes modal when cancel is clicked and stays on dashboard", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dashboard")

      # Open modal
      live
      |> element("button", "Add New Expense")
      |> render_click()

      # Verify modal is shown
      assert has_element?(live, "#expense-modal")

      # Close modal by triggering the JS command (simulating the X button click)
      # The modal's on_cancel triggers JS.push("close_modal")
      assert live |> render_click("close_modal", %{})

      # Verify modal is closed
      refute has_element?(live, "#expense-modal")
      
      # Verify we're still on the dashboard
      assert render(live) =~ "Welcome"
      assert render(live) =~ "Recent Expenses"
    end

    test "displays existing expenses in recent expenses section", %{conn: conn, user: user} do
      # Create some expenses
      expense1 = expense_fixture(%{
        created_by_id: user.id,
        title: "First Expense",
        description: "First Description"
      })
      
      expense2 = expense_fixture(%{
        created_by_id: user.id,
        title: "Second Expense",
        description: "Second Description"
      })

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      # Verify expenses are shown
      assert html =~ expense1.title
      assert html =~ expense1.description
      assert html =~ expense2.title
      assert html =~ expense2.description
    end

    test "displays existing groups in groups section", %{conn: conn, user: user} do
      # Create a group and add user to it
      group = group_fixture_with_user(user, %{name: "Test Group"})

      {:ok, _live, html} = live(conn, ~p"/dashboard")

      # Verify group is shown
      assert html =~ group.name
    end

    test "modal form validation shows errors", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/dashboard")

      # Open modal
      live
      |> element("button", "Add New Expense")
      |> render_click()

      # Submit invalid form
      assert live
             |> form("#expense-form", expense: %{title: nil, amount_display: nil})
             |> render_change() =~ "can&#39;t be blank"
    end

    test "expense modal allows selecting groups", %{conn: conn, user: user} do
      # Create a group first and add user to it
      group = group_fixture_with_user(user, %{name: "Test Group for Expense"})

      {:ok, live, _html} = live(conn, ~p"/dashboard")

      # Open modal
      live
      |> element("button", "Add New Expense")
      |> render_click()

      # Verify group is available in the form
      html = render(live)
      assert html =~ group.name
      assert has_element?(live, "#expense-form select[name='expense[group_ids][]']")
    end
  end
end