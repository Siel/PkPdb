defmodule Core.Dataset.Search do
  alias Core.Repo
  import Ecto.Query, warn: false
  alias Core.Dataset.Metadata

  def do_search(query_str) do
    from(m in Metadata)
    |> search_filter(query_str)
    |> Repo.all()
  end

  defp search_filter(query, value) do
    values =
      value
      |> String.split(~r/ +/, trim: true)
      |> Enum.map(fn value ->
        "%" <> String.replace(value, ~r/[\b\W]+/, "%") <> "%"
      end)

    conditions =
      values
      |> Enum.reduce(false, fn v, acc_query ->
        dynamic(
          [t],
          ilike(t.citation, ^v) or ilike(t.name, ^v) or ilike(t.description, ^v) or ^acc_query
        )
      end)

    query
    |> where(^conditions)
  end
end
