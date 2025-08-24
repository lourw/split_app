defmodule SplitAppWeb.GroupLive.Index do
  use SplitAppWeb, :live_view

  alias SplitApp.Groups
  alias SplitApp.Groups.Group

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    groups = Groups.list_user_groups(user)
    {:ok, stream(socket, :groups, groups)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = socket.assigns.current_user

    socket
    |> assign(:page_title, "Edit Group")
    |> assign(:group, Groups.get_user_group!(user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Group")
    |> assign(:group, %Group{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Groups")
    |> assign(:group, nil)
  end

  @impl true
  def handle_info({SplitAppWeb.GroupLive.FormComponent, {:saved, group}}, socket) do
    {:noreply, stream_insert(socket, :groups, group)}
  end

  def handle_info({SplitAppWeb.GroupLive.FormComponent, {:put_flash, {type, message}}}, socket) do
    {:noreply, put_flash(socket, type, message)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    group = Groups.get_user_group!(user, id)

    case Groups.delete_user_group(user, group) do
      {:ok, _} ->
        {:noreply, stream_delete(socket, :groups, group)}

      {:error, :unauthorized} ->
        {:noreply,
         socket
         |> put_flash(:error, "You are not authorized to delete this group")
         |> push_navigate(to: ~p"/groups")}
    end
  end
end
