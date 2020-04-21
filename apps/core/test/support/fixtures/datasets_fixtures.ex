defmodule Core.DatasetsFixtures do
  alias Core.Dataset

  def dataset_fixture(data, type) do
    user = Core.AccountsFixtures.user_fixture()

    {:ok, ds} =
      Dataset.init!(type)
      |> Dataset.update_metadata!(%{name: "Valid name", share: "free", owner_id: user.id})
      |> Dataset.parse_events!(data)
      |> Dataset.save()

    ds
  end
end
