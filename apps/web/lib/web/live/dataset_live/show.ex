defmodule Web.DatasetLive.Show do
  use Web, :live_view
  alias Core.Dataset

  @impl true
  def mount(%{"id" => id}, session, socket) do
    {:ok,
     case Dataset.get(id) do
       {:ok, dataset} ->
         owner? =
           case session["user_token"] do
             nil ->
               false

             token ->
               user = Core.Accounts.get_user_by_session_token(token)
               dataset.owner_id == user.id
           end

         socket
         |> assign(:dataset, dataset)
         |> assign(:owner, Core.Accounts.get_user!(dataset.owner_id))
         |> assign(:downloads, Dataset.get_downloads(dataset))
         |> assign(:owner?, owner?)

       {:error, error} ->
         socket
         |> put_flash(:error, inspect(error))
         |> redirect(to: Routes.page_path(socket, :index))
     end}
  end

  @impl true
  def handle_event("transform", %{"target" => target}, socket) do
    if socket.assigns.owner? do
      IO.inspect(target)
      IO.inspect(socket.assigns.dataset)

      # TODO: change get to receive the actual dataset and not this mess (btw preventing the doble call to the db)
      {:ok, ds} =
        socket.assigns.dataset
        |> Dataset.transform_to(target)
        |> Dataset.save()

      # {:ok, dataset} = Dataset.get(ds.dataset.id)

      # {:noreply, socket |> assign(:dataset, dataset)}
      # TODO: reassinging the dataset breaks the graph, im refreshing the webpage, look for a fix
      {:noreply, redirect(socket, to: "/datasets/#{ds.dataset.id}")}
    else
      {:noreply, socket}
    end
  end

  defp dataset_unsupported_types(%Dataset{} = dataset) do
    Dataset.unsupported_types(dataset)
  end

  defp plot_data(%Dataset{} = dataset) do
    Dataset.plot_data(dataset)
  end
end
