defmodule Web.DatasetController do
  use Web, :controller
  alias Core.Dataset

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"dataset" => dataset = %{"file" => file, "format" => format}})
      when format in ["nonmem", "pmetrics"] do
    case Dataset.init()
         |> Dataset.update_attr!(%{
           type: format,
           name: dataset["name"],
           description: dataset["description_text"],
           citation: dataset["citation_text"],
           share: "free"
         })
         |> Dataset.parse_events!(File.read!(file.path))
         |> Dataset.save!() do
      {:ok, dataset} ->
        dataset

      {:error, error} ->
        error
    end
    |> IO.inspect()

    render(conn, "new.html")
  end
end
