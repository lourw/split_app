defmodule SplitAppWeb.LandingComponents do
  use Phoenix.Component
  import SplitAppWeb.CoreComponents

  @doc "A reusable card component to display information"
  attr :icon, :string, required: true
  attr :header, :string, required: true
  attr :description, :string, required: true

  def info_card(assigns) do
    ~H"""
    <div class="text-left flex flex-col hover:opacity-75 flex-1 bg-slate-100 shadow-md border-slate-200 rounded-lg
    py-4 px-6 gap-3">
      <.icon name={@icon} />
      <h3 class="flex items-center gap-2 text-lg font-semibold">
        {@header}
      </h3>

      <p class="text-sm text-gray-600">
        {@description}
      </p>
    </div>
    """
  end
end
