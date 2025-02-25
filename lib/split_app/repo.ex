defmodule SplitApp.Repo do
  use Ecto.Repo,
    otp_app: :split_app,
    adapter: Ecto.Adapters.SQLite3
end
