defmodule Web.DatasetController do
  use Web, :controller
  alias Core.Dataset

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"dataset" => dataset = %{"file" => file, "format" => format}})
      when format in ["nonmem", "pmetrics"] do
    case Dataset.init!(format)
         |> Dataset.update_metadata!(%{
           name: dataset["name"],
           description: dataset["description_text"],
           citation: dataset["citation_text"],
           share: "free",
           owner_id: conn.assigns[:current_user].id
         })
         |> Dataset.parse_events!(File.read!(file.path))
         |> Dataset.save() do
      {:ok, dataset} ->
        redirect(conn, to: Routes.dataset_path(conn, :show, dataset.dataset.id))

      {:error, _error} ->
        redirect(conn, to: Routes.dataset_path(conn, :new))
    end
  end

  def show(conn, %{"id" => id}) do
    case Dataset.get(id, :metadata) do
      {:ok, dataset} ->
        render(conn, "show.html", dataset: dataset)

      {:error, error} ->
        conn
        |> put_flash(:error, inspect(error))
        |> render("index.html")
    end
  end

  def basic_search(conn, %{"search" => %{"query" => query}}) do
    results = Dataset.search(query)
    render(conn, "search_results.html", results: results)
  end
end
