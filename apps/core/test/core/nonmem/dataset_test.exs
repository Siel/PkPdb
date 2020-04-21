defmodule Core.Dataset.Nonmem.DatasetTest do
  use Core.DataCase
  alias Core.Dataset

  defp valid_dataset(data, type) do
    {:ok, ds} =
      Dataset.init!(type)
      |> Dataset.update_metadata!(%{name: "Valid name", share: "free"})
      |> Dataset.parse_events!(data)
      |> Dataset.save()

    ds
  end

  describe "Dataset" do
    test "Create a Nonmem Dataset" do
      assert %Dataset{valid?: false, type: "nonmem"} =
               Dataset.init!("nonmem")
               |> Dataset.update_metadata!(%{})
    end

    test "Creating a pmetric dataset, transforming it to nonmem and the saving it" do
      data = File.read!("test/data/dnr_mini.csv")

      ds = valid_dataset(data, "pmetrics")

      dataset1 = Dataset.get(ds.dataset.id)

      {:ok, nmds} =
        dataset1
        |> Dataset.transform_to("nonmem")
        |> Dataset.save()

      dataset2 = Dataset.get(nmds.dataset.id, "nonmem")
      assert(length(dataset1.events) == length(dataset2.events))

      assert(
        dataset1.events
        |> Enum.all?(fn event ->
          match?(
            %Ecto.Changeset{valid?: true},
            Core.Dataset.Pmetrics.Event.changeset(%Core.Dataset.Pmetrics.Event{}, event)
          )
        end)
      )

      assert(
        dataset2.events
        |> Enum.all?(fn event ->
          match?(
            %Ecto.Changeset{valid?: true},
            Core.Dataset.Nonmem.Event.changeset(%Core.Dataset.Nonmem.Event{}, event)
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
