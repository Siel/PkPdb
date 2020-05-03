defmodule Core.Dataset.Nonmem.DatasetTest do
  use Core.DataCase
  alias Core.Dataset

  describe "Dataset" do
    test "Create a Nonmem Dataset" do
      assert %Dataset{valid?: false, type: "nonmem"} =
               Dataset.init!("nonmem")
               |> Dataset.update_metadata!(%{})
    end

    test "Creating a pmetrics dataset, transforming it to nonmem and the saving it" do
      data = File.read!("test/data/dnr_mini.csv")

      ds = Core.DatasetsFixtures.dataset_fixture(data, "pmetrics")

      {:ok, dataset1} = Dataset.get(ds.dataset.id)

      {:ok, nmds} =
        dataset1
        |> Dataset.transform_to("nonmem")
        |> Dataset.save()

      {:ok, dataset2} = Dataset.get(nmds.dataset.id, "nonmem")
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

    test "" do
      data = File.read!("test/data/dnr_mini_nonmem.csv")

      ds = Core.DatasetsFixtures.dataset_fixture(data, "nonmem")

      {:ok, dataset} = Dataset.get(ds.dataset.id)

      # dataset |> IO.inspect()

      rendered_data = Core.Dataset.render(dataset)

      # ds2 = Core.DatasetsFixtures.dataset_fixture(rendered_data, "nonmem")

      # {:ok, dataset2} = Dataset.get(ds2.dataset.id)

      # dataset = dataset |> remove_ids_from_dataset()

      # dataset2 = dataset2 |> remove_ids_from_dataset()

      # assert(dataset == dataset2)
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
