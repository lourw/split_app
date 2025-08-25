defmodule SplitAppWeb.ExpenseLive.Index do
  use SplitAppWeb, :live_view

  import SplitAppWeb.LiveHelpers

  alias SplitApp.Expenses
  alias SplitApp.Expenses.Expense

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    expenses = if current_user, do: Expenses.list_expenses_by_user(current_user.id), else: []
    {:ok, socket |> stream(:expenses, expenses) |> assign(:expenses_count, length(expenses))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Expense")
    |> assign(:expense, Expenses.get_expense!(id))
  end

  defp apply_action(socket, :new, _params) do
    current_user = socket.assigns.current_user

    socket
    |> assign(:page_title, "New Expense")
    |> assign(:expense, %Expense{created_by_id: current_user.id})
  end

  defp apply_action(socket, :index, _params) do
    current_user = socket.assigns.current_user
    expenses = if current_user, do: Expenses.list_expenses_by_user(current_user.id), else: []

    socket
    |> assign(:page_title, "Listing Expenses")
    |> assign(:expense, nil)
    |> stream(:expenses, expenses, reset: true)
    |> assign(:expenses_count, length(expenses))
  end

  @impl true
  def handle_info({SplitAppWeb.ExpenseLive.FormComponent, {:saved, expense}}, socket) do
    {:noreply,
     socket
     |> stream_insert(:expenses, expense)
     |> assign(:expenses_count, socket.assigns.expenses_count + 1)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expense = Expenses.get_expense!(id)
    {:ok, _} = Expenses.delete_expense(expense)

    {:noreply,
     socket
     |> stream_delete(:expenses, expense)
     |> assign(:expenses_count, socket.assigns.expenses_count - 1)}
  end
end
