defmodule Core.Dataset.Pmetrics.DatasetTest do
  use Core.DataCase
  alias Core.Dataset

  describe "Dataset" do
    test "create an empty Dataset" do
      assert %Dataset{valid?: false} = Dataset.init()
    end

    test "Create a Pmetrics Dataset" do
      assert %Dataset{valid?: false, type: "pmetrics"} =
               Dataset.init()
               |> Dataset.update_attr!(%{type: "pmetrics"})
    end

    test "Attempt to update_attr whithout type will raise an error" do
      assert_raise(
        RuntimeError,
        fn ->
          Dataset.init()
          |> Dataset.update_attr!(%{})
        end
      )
    end

    test "parse_events!/2 " do
      data = File.read!("test/data/dnr.csv")

      ds =
        Dataset.init()
        |> Dataset.update_attr!(%{type: "pmetrics"})
        |> Dataset.parse_events!(data)

      assert ds.events != nil
      assert is_list(ds.events)
    end

    test "Pmetrics events are getting stored in the DB" do
      data = File.read!("test/data/dnr.csv")

      ds =
        Dataset.init()
        |> Dataset.update_attr!(%{type: "pmetrics"})
        |> Dataset.parse_events!(data)
        |> Dataset.save!()

      assert {:ok, _} = ds
    end

    test "Create a Pmetrics dataset and transform it to Nonmem" do
      data = File.read!("test/data/dnr_mini.csv")

      {:ok, ds} =
        Dataset.init()
        |> Dataset.update_attr!(%{type: "pmetrics"})
        |> Dataset.parse_events!(data)
        |> Dataset.save!()

      dataset = Dataset.get(ds.dataset.id)

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

      {:ok, ds} =
        Dataset.init()
        |> Dataset.update_attr!(%{type: "pmetrics"})
        |> Dataset.parse_events!(data)
        |> Dataset.save!()

      dataset = Dataset.get(ds.dataset.id)

      rendered_data = Core.Dataset.render(dataset)

      {:ok, ds2} =
        Dataset.init()
        |> Dataset.update_attr!(%{type: "pmetrics"})
        |> Dataset.parse_events!(rendered_data)
        |> Dataset.save!()

      dataset2 = Dataset.get(ds2.dataset.id)

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
        Map.drop(event, [:metadata, :metadata_id, :id])
      end)
    end)
    |> Map.drop([:id])
  end
end
