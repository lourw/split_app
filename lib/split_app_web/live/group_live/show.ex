defmodule SplitAppWeb.GroupLive.Show do
  use SplitAppWeb, :live_view

  import SplitAppWeb.LiveHelpers

  alias SplitApp.Groups

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = socket.assigns.current_user

    try do
      group = Groups.get_user_group!(user, id)

      {:noreply,
       socket
       |> assign(:page_title, page_title(socket.assigns.live_action))
       |> assign(:group, group)}
    rescue
      Ecto.NoResultsError ->
        {:noreply,
         socket
         |> put_flash(:error, "Group not found or you don't have access")
         |> push_navigate(to: ~p"/groups")}
    end
  end

  @impl true
  def handle_info({SplitAppWeb.GroupLive.FormComponent, {:saved, group}}, socket) do
    {:noreply, assign(socket, :group, group)}
  end

  def handle_info({SplitAppWeb.GroupLive.FormComponent, {:put_flash, {type, message}}}, socket) do
    {:noreply, put_flash(socket, type, message)}
  end

  defp page_title(:show), do: "Show Group"
  defp page_title(:edit), do: "Edit Group"

  defp get_user_count(%{users: users}) when is_list(users), do: length(users)
  defp get_user_count(_), do: 0
end
