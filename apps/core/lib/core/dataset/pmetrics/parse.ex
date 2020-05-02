defmodule Core.Dataset.Pmetrics.Parse do
  @moduledoc false
  alias NimbleCSV.RFC4180, as: Nimble
  import Core.Dataset.ParseHelpers, only: [merge: 3, type: 2]

  def parse_events(str) do
    [headers | events] =
      str
      |> Nimble.parse_string()

    cov_names =
      headers
      |> Enum.drop(14)
      |> Enum.map(&String.to_atom/1)

    events
    |> Enum.filter(fn [h | _t] -> not String.starts_with?(h, "#") end)
    |> Enum.map(&map_pmetrics/1)
    |> Enum.map(fn event -> Map.update!(event, :cov, &set_cov_names(&1, cov_names)) end)
  end

  defp set_cov_names(events, cov_names) do
    {:ok, cov} = merge(events, cov_names, fn x, y -> {y, x} end)

    cov
    |> Enum.into(%{})
  end

  defp map_pmetrics(row) do
    [
      subject
      | [
          evid
          | [
              time
              | [
                  dur
                  | [
                      dose
                      | [
                          addl
                          | [ii | [input | [out | [outeq | [c0 | [c1 | [c2 | [c3 | cov]]]]]]]]
                        ]
                    ]
                ]
            ]
        ]
    ] = row

    %{
      subject: subject,
      evid: evid |> type(:int),
      time: time |> type(:float),
      dur: dur |> type(:float),
      dose: dose |> type(:float),
      addl: addl |> type(:int),
      ii: ii |> type(:float),
      input: input |> type(:int),
      out: out |> type(:float),
      outeq: outeq |> type(:int),
      c0: c0 |> type(:float),
      c1: c1 |> type(:float),
      c2: c2 |> type(:float),
      c3: c3 |> type(:float),
      cov: cov
    }
  end
end
