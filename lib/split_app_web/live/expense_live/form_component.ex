defmodule SplitAppWeb.ExpenseLive.FormComponent do
  use SplitAppWeb, :live_component

  alias SplitApp.Expenses
  alias SplitApp.Expenses.Expense
  alias SplitApp.Groups

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
        <.input
          field={@form[:group_ids]}
          type="select"
          label="Groups"
          multiple={true}
          options={@group_options}
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

    # Get the current user's groups for the dropdown
    group_options =
      if assigns.current_user do
        Groups.list_user_groups(assigns.current_user)
        |> Enum.map(fn group -> {group.name, group.id} end)
      else
        []
      end

    # Get current expense groups if editing
    selected_groups =
      if expense.id do
        loaded_expense = Expenses.get_expense_with_associations!(expense.id)
        Enum.map(loaded_expense.groups, & &1.id)
      else
        []
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:group_options, group_options)
     |> assign(:selected_groups, selected_groups)
     |> assign_new(:form, fn ->
       changeset
       |> Map.put(:changes, Map.put(changeset.changes, :group_ids, selected_groups))
       |> to_form()
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
    # Extract group_ids and remove from params
    {group_ids, params_without_groups} = Map.pop(expense_params, "group_ids", [])

    # Convert group_ids to integers
    group_ids = Enum.map(group_ids || [], &String.to_integer/1)

    result =
      if group_ids == [] do
        Expenses.update_expense(socket.assigns.expense, params_without_groups)
      else
        Expenses.update_expense_with_groups(
          socket.assigns.expense,
          params_without_groups,
          group_ids
        )
      end

    case result do
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

    # Extract group_ids and remove from params
    {group_ids, params_without_groups} = Map.pop(params_with_user, "group_ids", [])

    # Convert group_ids to integers
    group_ids = Enum.map(group_ids || [], &String.to_integer/1)

    result =
      if group_ids == [] do
        Expenses.create_expense(params_without_groups)
      else
        Expenses.create_expense_with_groups(params_without_groups, group_ids)
      end

    case result do
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
