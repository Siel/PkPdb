defmodule Core.DatasetTest do
  use Core.DataCase

  alias Core.Dataset
  alias Core.Repo

  describe "Dataset" do
    test "create a dummy dataset" do
      assert %Dataset{valid?: false} =
               Dataset.dummy_dataset()
    end
  end
end
