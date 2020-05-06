defmodule Web.DatasetLive.Show do
  use Web, :live_view
  alias Core.Dataset

  @impl true
  def mount(%{"id" => id}, session, socket) do
    {:ok,
     case Dataset.get(id) do
       {:ok, dataset} ->
         {current_user, owner?} =
           case session["user_token"] do
             nil ->
               {nil, false}

             token ->
               user = Core.Accounts.get_user_by_session_token(token)
               {user, dataset.owner_id == user.id}
           end

         socket
         |> assign(:dataset, dataset)
         |> assign(:owner, Core.Accounts.get_user!(dataset.owner_id))
         |> assign(:downloads, Dataset.get_downloads(dataset))
         |> assign(:owner?, owner?)
         |> assign(:current_user, current_user)
         |> assign(:comments, Dataset.get_comments(dataset))

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

  @imp true
  def handle_event("save", %{"comment" => %{"content" => content}}, socket) do
    IO.inspect(content)
    IO.inspect(socket.assigns[:current_user])

    # TODO: re-think this to avoid double calling the db
    {:ok, _} =
      Dataset.new_comment(socket.assigns[:dataset], content, socket.assigns[:current_user].id)

    # {:ok, _comments} = Dataset.get_comments(socket.assigns[:dataset])

    # {:noreply, socket |> assign(:comments, comments)}
    # TODO: reassinging the dataset breaks the graph, im refreshing the webpage, look for a fix
    {:noreply, redirect(socket, to: "/datasets/#{socket.assigns[:dataset].id}")}
  end

  defp dataset_unsupported_types(%Dataset{} = dataset) do
    Dataset.unsupported_types(dataset)
  end

  defp plot_data(%Dataset{} = dataset) do
    Dataset.plot_data(dataset)
  end
end
