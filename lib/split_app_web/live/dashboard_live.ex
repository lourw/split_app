defmodule SplitAppWeb.DashboardLive do
  use SplitAppWeb, :live_view
  alias SplitApp.Groups
  alias SplitApp.Groups.Group
  alias SplitApp.Expenses
  alias SplitApp.Expenses.Expense

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    groups = Groups.list_user_groups(user)
    recent_expenses = Expenses.list_expenses_by_user(user.id) |> Enum.take(5)

    {:ok,
     socket
     |> assign(:groups, groups)
     |> assign(:recent_expenses, recent_expenses)
     |> assign(:page_title, "Dashboard")
     |> assign(:show_expense_modal, false)
     |> assign(:expense, nil)
     |> assign(:show_group_modal, false)
     |> assign(:group, nil)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("new_expense", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_expense_modal, true)
     |> assign(:expense, %Expense{created_by_id: socket.assigns.current_user.id})}
  end

  @impl true
  def handle_event("new_group", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_group_modal, true)
     |> assign(:group, %Group{})}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_expense_modal, false)
     |> assign(:expense, nil)
     |> assign(:show_group_modal, false)
     |> assign(:group, nil)}
  end

  @impl true
  def handle_event("close_expense_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_expense_modal, false)
     |> assign(:expense, nil)}
  end

  @impl true
  def handle_event("close_group_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_group_modal, false)
     |> assign(:group, nil)}
  end

  @impl true
  def handle_info({SplitAppWeb.ExpenseLive.FormComponent, {:saved, _expense}}, socket) do
    user = socket.assigns.current_user
    recent_expenses = Expenses.list_expenses_by_user(user.id) |> Enum.take(5)
    
    {:noreply,
     socket
     |> assign(:recent_expenses, recent_expenses)
     |> assign(:show_expense_modal, false)
     |> assign(:expense, nil)
     |> put_flash(:info, "Expense created successfully")}
  end

  @impl true
  def handle_info({SplitAppWeb.GroupLive.FormComponent, {:saved, _group}}, socket) do
    user = socket.assigns.current_user
    groups = Groups.list_user_groups(user)
    
    {:noreply,
     socket
     |> assign(:groups, groups)
     |> assign(:show_group_modal, false)
     |> assign(:group, nil)}
  end

  @impl true
  def handle_info({SplitAppWeb.GroupLive.FormComponent, {:put_flash, {type, message}}}, socket) do
    {:noreply, put_flash(socket, type, message)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-6xl">
      <.header>
        Welcome, {@current_user.email}!
        <:subtitle>Manage your expenses and groups</:subtitle>
      </.header>
      
    <!-- Quick Actions -->
      <div class="mt-8 grid grid-cols-1 gap-4 sm:grid-cols-2">
        <button phx-click="new_expense" class="group text-left">
          <div class="rounded-lg border-2 border-dashed border-gray-300 p-6 text-center hover:border-gray-400 transition-colors">
            <div class="mx-auto h-12 w-12 text-gray-400 group-hover:text-gray-500">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M12 6v12m-3-2.818l.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
            </div>
            <h3 class="mt-2 text-lg font-semibold text-gray-900">Add New Expense</h3>
            <p class="mt-1 text-sm text-gray-500">
              Track a new expense and split it with your groups
            </p>
          </div>
        </button>

        <button phx-click="new_group" class="group text-left">
          <div class="rounded-lg border-2 border-dashed border-gray-300 p-6 text-center hover:border-gray-400 transition-colors">
            <div class="mx-auto h-12 w-12 text-gray-400 group-hover:text-gray-500">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M18 18.72a9.094 9.094 0 003.741-.479 3 3 0 00-4.682-2.72m.94 3.198l.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0112 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 016 18.719m12 0a5.971 5.971 0 00-.941-3.197m0 0A5.995 5.995 0 0012 12.75a5.995 5.995 0 00-5.058 2.772m0 0a3 3 0 00-4.681 2.72 8.986 8.986 0 003.74.477m.94-3.197a5.971 5.971 0 00-.94 3.197M15 6.75a3 3 0 11-6 0 3 3 0 016 0zm6 3a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0zm-13.5 0a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0z"
                />
              </svg>
            </div>
            <h3 class="mt-2 text-lg font-semibold text-gray-900">Create New Group</h3>
            <p class="mt-1 text-sm text-gray-500">Start a new group to organize shared expenses</p>
          </div>
        </button>
      </div>
      
    <!-- Recent Expenses -->
      <div class="mt-12">
        <div class="flex items-center justify-between">
          <h2 class="text-xl font-semibold text-gray-900">Recent Expenses</h2>
          <.link
            navigate={~p"/expenses"}
            class="text-sm font-medium text-indigo-600 hover:text-indigo-500"
          >
            View all expenses →
          </.link>
        </div>

        <%= if @recent_expenses == [] do %>
          <div class="mt-6 text-center py-12 bg-gray-50 rounded-lg">
            <div class="mx-auto h-12 w-12 text-gray-400">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 0 0 2.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 0 0-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-.1-.664m-5.8 0A2.251 2.251 0 0 1 13.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25ZM6.75 12h.008v.008H6.75V12Zm0 3h.008v.008H6.75V15Zm0 3h.008v.008H6.75V18Z"
                />
              </svg>
            </div>
            <h3 class="mt-2 text-sm font-semibold text-gray-900">No expenses yet</h3>
            <p class="mt-1 text-sm text-gray-500">Get started by adding your first expense.</p>
          </div>
        <% else %>
          <div class="mt-6 bg-white shadow overflow-hidden sm:rounded-md">
            <ul class="divide-y divide-gray-200">
              <%= for expense <- @recent_expenses do %>
                <li>
                  <.link navigate={~p"/expenses/#{expense}"} class="block hover:bg-gray-50">
                    <div class="px-4 py-4 sm:px-6">
                      <div class="flex items-center justify-between">
                        <div class="flex items-center">
                          <div>
                            <p class="text-sm font-medium text-indigo-600 truncate">
                              {expense.title}
                            </p>
                            <p class="mt-2 text-sm text-gray-500">
                              {expense.description}
                            </p>
                          </div>
                        </div>
                        <div class="ml-2 flex-shrink-0 flex">
                          <p class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                            {format_money(expense.amount)}
                          </p>
                        </div>
                      </div>
                    </div>
                  </.link>
                </li>
              <% end %>
            </ul>
          </div>
        <% end %>
      </div>
      
    <!-- Groups Section -->
      <div class="mt-12">
        <div class="flex items-center justify-between">
          <h2 class="text-xl font-semibold text-gray-900">Your Groups</h2>
          <.link
            navigate={~p"/groups"}
            class="text-sm font-medium text-indigo-600 hover:text-indigo-500"
          >
            View all groups →
          </.link>
        </div>

        <div class="mt-6">
          <%= if @groups == [] do %>
            <div class="text-center py-12 bg-gray-50 rounded-lg">
              <div class="mx-auto h-12 w-12 text-gray-400">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke-width="1.5"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z"
                  />
                </svg>
              </div>
              <h3 class="mt-2 text-sm font-semibold text-gray-900">No groups yet</h3>
              <p class="mt-1 text-sm text-gray-500">Get started by creating a new group.</p>
            </div>
          <% else %>
            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
              <%= for group <- @groups do %>
                <.link navigate={~p"/groups/#{group}"} class="group">
                  <div class="relative rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm hover:border-gray-400 hover:shadow-md transition-all">
                    <div>
                      <span class="inline-flex rounded-lg bg-indigo-50 p-3 text-indigo-600">
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke-width="1.5"
                          stroke="currentColor"
                          class="h-6 w-6"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M18 18.72a9.094 9.094 0 003.741-.479 3 3 0 00-4.682-2.72m.94 3.198l.001.031c0 .225-.012.447-.037.666A11.944 11.944 0 0112 21c-2.17 0-4.207-.576-5.963-1.584A6.062 6.062 0 016 18.719m12 0a5.971 5.971 0 00-.941-3.197m0 0A5.995 5.995 0 0012 12.75a5.995 5.995 0 00-5.058 2.772m0 0a3 3 0 00-4.681 2.72 8.986 8.986 0 003.74.477m.94-3.197a5.971 5.971 0 00-.94 3.197M15 6.75a3 3 0 11-6 0 3 3 0 016 0zm6 3a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0zm-13.5 0a2.25 2.25 0 11-4.5 0 2.25 2.25 0 014.5 0z"
                          />
                        </svg>
                      </span>
                    </div>
                    <div class="mt-4">
                      <h3 class="text-base font-semibold leading-6 text-gray-900">
                        {group.name}
                      </h3>
                      <p class="mt-2 text-sm text-gray-500 line-clamp-2">
                        {group.description || "No description provided"}
                      </p>
                    </div>
                    <span
                      class="pointer-events-none absolute right-6 top-6 text-gray-300 group-hover:text-gray-400"
                      aria-hidden="true"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="1.5"
                        stroke="currentColor"
                        class="h-6 w-6"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M8.25 4.5l7.5 7.5-7.5 7.5"
                        />
                      </svg>
                    </span>
                  </div>
                </.link>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <.modal
      :if={@show_expense_modal}
      id="expense-modal"
      show
      on_cancel={JS.push("close_expense_modal")}
    >
      <.live_component
        module={SplitAppWeb.ExpenseLive.FormComponent}
        id={:new}
        title="New Expense"
        action={:new}
        expense={@expense}
        current_user={@current_user}
        patch={~p"/dashboard"}
      />
    </.modal>

    <.modal
      :if={@show_group_modal}
      id="group-modal"
      show
      on_cancel={JS.push("close_group_modal")}
    >
      <.live_component
        module={SplitAppWeb.GroupLive.FormComponent}
        id={:new}
        title="New Group"
        action={:new}
        group={@group}
        current_user={@current_user}
        patch={~p"/dashboard"}
      />
    </.modal>
    """
  end

  defp format_money(%Money{amount: amount_cents, currency: currency}) do
    amount_float = amount_cents / 100
    "#{:erlang.float_to_binary(amount_float, decimals: 2)} #{currency}"
  end

  defp format_money(_), do: "-"
end
