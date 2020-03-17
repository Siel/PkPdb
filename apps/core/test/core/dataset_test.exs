defmodule Core.DatasetTest do
  use Core.DataCase

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

    test "parse_events!/2 " do
      data = File.read!("test/data/dnr.csv")

      ds =
        Dataset.init()
        |> Dataset.update_attr!(%{type: "pmetrics"})
        |> Dataset.parse_events!(data)

      assert ds.events != nil
      assert is_list(ds.events)
    end

    test "PMevents are getting stored in the DB" do
      data = File.read!("test/data/dnr.csv")

      ds =
        Dataset.init()
        |> Dataset.update_attr!(%{type: "pmetrics"})
        |> Dataset.parse_events!(data)
        |> Dataset.validate()
        |> Dataset.save!()

      assert {:ok, _} = ds
    end
  end
end
