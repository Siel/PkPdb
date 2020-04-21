defmodule Web.DatasetController do
  use Web, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"dataset" => dataset}) do
    Logger.info(inspect(dataset))
    render(conn, "new.html")
  end
end
