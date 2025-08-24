defmodule SplitAppWeb.ExpenseLive.FormComponent do
  use SplitAppWeb, :live_component

  alias SplitApp.Expenses
  alias SplitApp.Expenses.Expense

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage expense records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="expense-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:amount_display]} type="text" label="Amount" placeholder="e.g., 25.50" />
        <.input
          field={@form[:currency]}
          type="select"
          label="Currency"
          options={[{"USD", "USD"}, {"EUR", "EUR"}, {"GBP", "GBP"}]}
          value="USD"
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Expense</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{expense: expense} = assigns, socket) do
    changeset = prepare_changeset_for_form(expense)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)}
  end

  @impl true
  def handle_event("validate", %{"expense" => expense_params}, socket) do
    processed_params = process_money_params(expense_params)
    changeset = Expenses.change_expense(socket.assigns.expense, processed_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expense" => expense_params}, socket) do
    processed_params = process_money_params(expense_params)
    save_expense(socket, socket.assigns.action, processed_params)
  end

  defp save_expense(socket, :edit, expense_params) do
    case Expenses.update_expense(socket.assigns.expense, expense_params) do
      {:ok, expense} ->
        notify_parent({:saved, expense})

        {:noreply,
         socket
         |> put_flash(:info, "Expense updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expense(socket, :new, expense_params) do
    params_with_user =
      Map.put(expense_params, "created_by_id", socket.assigns.expense.created_by_id)

    case Expenses.create_expense(params_with_user) do
      {:ok, expense} ->
        notify_parent({:saved, expense})

        {:noreply,
         socket
         |> put_flash(:info, "Expense created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp process_money_params(%{"amount_display" => amount_str, "currency" => currency} = params)
       when amount_str != "" do
    case Float.parse(amount_str) do
      {amount_float, ""} ->
        amount_cents = trunc(amount_float * 100)
        money = Money.new(amount_cents, currency)

        params
        |> Map.put("amount", money)
        |> Map.delete("amount_display")
        |> Map.delete("currency")

      _ ->
        Map.delete(params, "amount")
    end
  end

  defp process_money_params(params), do: params

  defp prepare_changeset_for_form(%Expense{amount: nil} = expense) do
    Expenses.change_expense(expense, %{amount_display: "", currency: "USD"})
  end

  defp prepare_changeset_for_form(
         %Expense{amount: %Money{amount: amount_cents, currency: currency}} = expense
       ) do
    amount_display = :erlang.float_to_binary(amount_cents / 100, decimals: 2)

    Expenses.change_expense(expense, %{
      amount_display: amount_display,
      currency: Atom.to_string(currency)
    })
  end

  defp prepare_changeset_for_form(%Expense{} = expense) do
    Expenses.change_expense(expense, %{amount_display: "", currency: "USD"})
  end
end
