defmodule SplitAppWeb.ExpenseLive.Show do
  use SplitAppWeb, :live_view

  import SplitAppWeb.LiveHelpers

  alias SplitApp.Expenses

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    expense = Expenses.get_expense_with_associations!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:expense, expense)}
  end

  defp page_title(:show), do: "Show Expense"
  defp page_title(:edit), do: "Edit Expense"
end
