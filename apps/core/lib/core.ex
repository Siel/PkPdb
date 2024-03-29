defmodule Core do
  @moduledoc """
  Core keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def log(element) do
    require Logger
    element |> inspect() |> Logger.info()
  end
end
