defmodule Core.DatasetTest do
  use Core.DataCase
  require Logger

  alias Core.Dataset
  alias Core.Repo

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

      dataset = Dataset.DB.get_dataset(ds.dataset.id)

      assert(dataset.type, "pmetrics")

      nonmem_dataset =
        dataset
        |> Dataset.transform(to: "nonmem")

      assert(nonmem_dataset.type == "nonmem")
      assert(nonmem_dataset.original_type == "pmetrics")
      assert(length(dataset.events) == length(nonmem_dataset.events))
    end
  end
end
