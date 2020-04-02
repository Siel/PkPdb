defmodule Core.Nonmem.DatasetTest do
  use Core.DataCase
  alias Core.Dataset

  describe "Dataset" do
    test "Create a Nonmem Dataset" do
      assert %Dataset{valid?: false, type: "nonmem"} =
               Dataset.init()
               |> Dataset.update_attr!(%{type: "nonmem"})
    end

    test "Creating a pmetric dataset, transforming it to nonmem and the saving it" do
      data = File.read!("test/data/dnr_mini.csv")

      {:ok, ds} =
        Dataset.init()
        |> Dataset.update_attr!(%{type: "pmetrics"})
        |> Dataset.parse_events!(data)
        |> Dataset.save!()

      dataset1 = Dataset.DB.get(ds.dataset.id)

      {:ok, nmds} =
        dataset1
        |> Dataset.transform_to("nonmem")
        |> Dataset.save!()

      dataset2 = Dataset.DB.get(nmds.dataset.id, "nonmem")
      assert(length(dataset1.events) == length(dataset2.events))

      assert(
        dataset1.events
        |> Enum.all?(fn event ->
          match?(
            %Ecto.Changeset{valid?: true},
            Core.Pmetrics.Event.changeset(%Core.Pmetrics.Event{}, event)
          )
        end)
      )

      assert(
        dataset2.events
        |> Enum.all?(fn event ->
          match?(
            %Ecto.Changeset{valid?: true},
            Core.Nonmem.Event.changeset(%Core.Nonmem.Event{}, event)
          )
        end)
      )
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
