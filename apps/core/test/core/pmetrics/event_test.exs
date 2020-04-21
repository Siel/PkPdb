defmodule Core.Dataset.Pmetrics.EventTest do
  use Core.DataCase

  alias Core.Dataset.Pmetrics.Event
  alias Core.Repo

  @valid_observation %{
    evid: 0,
    subject: "1",
    time: 0,
    dur: nil,
    dose: nil,
    addl: nil,
    ii: nil,
    input: 1,
    outeq: 1,
    out: 0,
    c0: nil,
    c1: nil,
    c2: nil,
    c3: nil
  }

  describe "data" do
    test "create an empty event returns error" do
      assert {:error, _} =
               %Event{}
               |> Event.changeset(%{})
               |> Repo.insert()
    end

    test "create a valid event returns ok" do
      {:ok, dataset} =
        Core.Dataset.init!("pmetrics")
        |> Core.Dataset.update_metadata!(%{name: "valid", share: "free"})
        |> Core.Dataset.save()

      assert {:ok, _} =
               %Event{}
               |> Event.changeset(
                 @valid_observation
                 |> Map.put(:metadata_id, dataset.dataset.id)
               )
               |> Repo.insert()
    end

    test "create a valid event without metadata_id returns error" do
      assert {:error, _} =
               %Event{}
               |> Event.changeset(@valid_observation)
               |> Repo.insert()
    end
  end
end
