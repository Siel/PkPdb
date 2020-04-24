defmodule Web.DatasetLive.Show do
  use Web, :live_view
  alias Core.Dataset

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket =
      case Dataset.get(id, :metadata) do
        {:ok, dataset} ->
          socket
          |> assign(:dataset, dataset)

        {:error, error} ->
          socket
          |> put_flash(:error, inspect(error))
          |> redirect(to: Routes.page_path(socket, :index))
      end

    {:ok, socket}
  end
end
