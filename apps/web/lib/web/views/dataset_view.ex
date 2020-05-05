defmodule Web.DatasetView do
  use Web, :view

  def owner_name(%{owner_id: owner_id}) do
    owner = Core.Accounts.get_user!(owner_id)
    "#{owner.name} #{owner.last_name}"
  end
end
