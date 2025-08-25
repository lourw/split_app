defmodule SplitAppWeb.LiveHelpers do
  @moduledoc """
  Shared helper functions for LiveView modules.
  """

  @doc """
  Formats a Money struct into a readable string.

  ## Examples

      iex> format_money(%Money{amount: 1250, currency: "USD"})
      "12.50 USD"
  """
  def format_money(%Money{amount: amount_cents, currency: currency}) do
    amount_float = amount_cents / 100
    "#{:erlang.float_to_binary(amount_float, decimals: 2)} #{currency}"
  end

  def format_money(_), do: "-"

  @doc """
  Formats a date/datetime into a readable string format.

  ## Examples

      iex> format_date(~D[2024-01-15])
      "Jan 15, 2024"
  """
  def format_date(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_date()
    |> Calendar.strftime("%b %d, %Y")
  end

  def format_date(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> NaiveDateTime.to_date()
    |> Calendar.strftime("%b %d, %Y")
  end

  def format_date(%Date{} = date) do
    Calendar.strftime(date, "%b %d, %Y")
  end

  def format_date(_), do: "-"
end
