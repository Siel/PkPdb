defmodule Web.DatasetView do
  use Web, :view

  def owner_name(%{owner_id: owner_id}) do
    owner = Core.Accounts.get_user!(owner_id)
    "#{owner.name} #{owner.last_name}"
  end

  def get_downloads(%Core.Dataset.Metadata{} = metadata) do
    # TODO: change this, just query the length
    length(Core.Dataset.get_downloads(%Core.Dataset{id: metadata.id, valid?: false}))
  end
end
