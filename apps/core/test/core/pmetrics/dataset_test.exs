defmodule Core.Dataset.Pmetrics.DatasetTest do
  use Core.DataCase
  alias Core.Dataset

  describe "Dataset" do
    test "create an empty Dataset" do
      assert %Dataset{valid?: false} = Dataset.init!("pmetrics")
    end

    test "Create a Pmetrics Dataset" do
      assert %Dataset{valid?: false, type: "pmetrics"} =
               Dataset.init!("pmetrics")
               |> Dataset.update_metadata!(%{})
    end

    test "Attempt to update_metadata whithout type will raise an error" do
      assert_raise(
        FunctionClauseError,
        fn ->
          Dataset.init!("")
          |> Dataset.update_metadata!(%{})
        end
      )
    end

    test "parse_events!/2 " do
      data = File.read!("test/data/dnr.csv")

      ds =
        Dataset.init!("pmetrics")
        |> Dataset.update_metadata!(%{name: "Valid name", share: "free"})
        |> Dataset.parse_events!(data)

      assert ds.events != nil
      assert is_list(ds.events)
    end

    test "Pmetrics events are getting stored in the DB" do
      data = File.read!("test/data/dnr.csv")

      ds = Core.DatasetsFixtures.dataset_fixture(data, "pmetrics")

      assert %{dataset: %Core.Dataset.Metadata{}} = ds
    end

    test "Create a Pmetrics dataset and transform it to Nonmem" do
      data = File.read!("test/data/dnr_mini.csv")

      ds = Core.DatasetsFixtures.dataset_fixture(data, "pmetrics")

      {:ok, dataset} = Dataset.get(ds.dataset.id)

      assert(dataset.type, "pmetrics")

      nonmem_dataset =
        dataset
        |> Dataset.transform_to("nonmem")

      assert(nonmem_dataset.type == "nonmem")
      assert(nonmem_dataset.original_type == "pmetrics")
      assert(length(dataset.events) == length(nonmem_dataset.events))
    end

    test "Core.Render.Pmetrics/1 generates the same original csv data" do
      data = File.read!("test/data/dnr_mini.csv")

      ds = Core.DatasetsFixtures.dataset_fixture(data, "pmetrics")

      {:ok, dataset} = Dataset.get(ds.dataset.id)

      rendered_data = Core.Dataset.render(dataset)

      ds2 = Core.DatasetsFixtures.dataset_fixture(rendered_data, "pmetrics")

      {:ok, dataset2} = Dataset.get(ds2.dataset.id)

      dataset = dataset |> remove_ids_from_dataset()

      dataset2 = dataset2 |> remove_ids_from_dataset()

      assert(dataset == dataset2)
    end
  end

  def remove_ids_from_dataset(dataset) do
    dataset
    |> Map.update!(:events, fn events ->
      events
      |> Enum.map(fn event ->
        Map.drop(event, [:metadata, :metadata_id, :id, :updated_at, :inserted_at])
      end)
    end)
    |> Map.drop([:id, :owner_id])
  end
end
