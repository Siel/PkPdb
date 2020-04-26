defmodule Web.PageController do
  use Web, :controller

  def index(conn, _params) do
    conn = conn |> assign(:index, true)
    render(conn, "index.html")
  end
end
