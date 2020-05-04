defmodule Web.DatasetController do
  use Web, :controller
  alias Core.Dataset

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"dataset" => dataset = %{"file" => file, "format" => format}})
      when format in ["nonmem", "pmetrics"] do
    IO.inspect("nada")

    with {:ok, parsed_dataset} <-
           Dataset.init!(format)
           |> Dataset.update_metadata!(%{
             name: dataset["name"],
             description: dataset["description_text"],
             citation: dataset["citation_text"],
             share: "free",
             owner_id: conn.assigns[:current_user].id
           })
           |> Dataset.parse_events(File.read!(file.path)),
         {:ok, dataset} <- Dataset.save(parsed_dataset) do
      redirect(conn, to: "/datasets/#{dataset.dataset.id}")
    else
      {:error, error} ->
        conn
        |> put_flash(:error, inspect(error))
        |> redirect(to: Routes.dataset_path(conn, :new))
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

  # TODO: do not hardcode the formats

  def download(conn, %{"id" => id, "format" => format}) when format in ["nonmem", "pmetrics"] do
    {:ok, dataset} = Dataset.get(id, format)
    owner = Core.Accounts.get_user!(dataset.owner_id)
    csv_content = Dataset.render(dataset)
    filename = "#{owner.last_name}-#{dataset.name |> String.replace(" ", "")}"
    Dataset.register_download(dataset, format, conn.assigns[:current_user].id)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}.csv\"")
    |> send_resp(200, csv_content)
  end

  def download(conn, _) do
    conn
    |> put_flash(:error, "Unsuported format")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
