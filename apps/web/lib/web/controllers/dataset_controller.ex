defmodule Web.DatasetController do
  use Web, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end
end
