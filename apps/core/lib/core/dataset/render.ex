defmodule Core.Dataset.Render do
  require EEx

  @templates "lib/core/dataset/templates"

  EEx.function_from_file(
    :def,
    :pmetrics,
    Path.join(@templates, "pmetrics.eex"),
    [:assigns]
  )

  defp cov_headers(cov_keys) do
    cov_keys
    |> Enum.reduce("", fn key, acc -> "#{acc},#{key}" end)
  end

  defp cov_row(cov, cov_keys) do
    Enum.reduce(
      cov_keys,
      "",
      fn key, acc ->
        "#{acc},#{cov[key] || "."}"
      end
    )
  end

  defp cov_keys(dataset) do
    dataset.events
    |> Enum.at(0)
    |> Map.get(:cov, %{})
    |> Enum.map(fn {k, _v} -> k end)
  end
end
