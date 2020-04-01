defmodule Core.Dataset.Render do
  require EEx

  @templates "lib/core/dataset/templates"

  File.ls!(@templates)
  |> Enum.filter(fn file -> String.ends_with?(file, ".eex") end)
  |> Enum.each(fn file ->
    EEx.function_from_file(
      :def,
      file |> String.trim_trailing(".eex") |> String.to_atom(),
      Path.join(@templates, file),
      [:assigns]
    )
  end)

  # EEx.function_from_file(
  #   :def,
  #   :nonmem,
  #   Path.join(@templates, "nonmem.eex"),
  #   [:assigns]
  # )

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
