defmodule SplitAppWeb.PageController do
  use SplitAppWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def sample(conn, _params) do
    render(conn, :sample)
  end
end
