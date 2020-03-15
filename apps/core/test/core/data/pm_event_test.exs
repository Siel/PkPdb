defmodule Core.PMEventTest do
  use Core.DataCase

  alias Core.Dataset.Data.PMEvent
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

  describe "Core" do
    test "create an empty event returns error" do
      assert {:error, _} =
               %PMEvent{}
               |> PMEvent.changeset(%{})
               |> Repo.insert()
    end

    test "create a valid event returns ok" do
      dataset = %{id: "123"}

      assert {:error, _} =
               %PMEvent{}
               |> PMEvent.changeset(
                 @valid_observation
                 |> Map.put(:dataset_id, dataset.id)
               )
               |> Repo.insert()
    end

    test "create a valid event without dataset_id returns error" do
      assert {:error, _} =
               %PMEvent{}
               |> PMEvent.changeset(@valid_observation)
               |> Repo.insert()
    end
  end
end
