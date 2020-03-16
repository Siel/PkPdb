defmodule Core.Datase.Parse.Pmetrics do
  alias NimbleCSV.RFC4180, as: Nimble

  def parse_pmetrics_data(str) do
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
    |> Enum.map(fn event -> Map.update!(event, :covs, &set_cov_names(&1, cov_names)) end)
  end

  defp set_cov_names(events, cov_names) do
    {:ok, cov} = merge(events, cov_names, fn x, y -> {y, x} end)
    cov
  end

  def merge(enum1, enum2, fun) when length(enum1) == length(enum2) do
    {:ok, do_merge(enum1, enum2, fun, [])}
  end

  def merge(_, _, _) do
    {:error, :size_mismatch}
  end

  defp do_merge([], [], _fun, acc) do
    Enum.reverse(acc)
  end

  defp do_merge(enum1, enum2, fun, acc) do
    [h1 | t1] = enum1
    [h2 | t2] = enum2

    do_merge(t1, t2, fun, [fun.(h1, h2) | acc])
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
                          | [ii | [input | [out | [outeq | [c0 | [c1 | [c2 | [c3 | covs]]]]]]]]
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
      covs: covs
    }
  end

  def type(str, type) do
    parse =
      case type do
        :float ->
          Float.parse(str)

        :int ->
          Integer.parse(str)
      end

    case parse do
      :error ->
        if str == ".", do: nil, else: raise("error: unable to parse")

      {val, _} ->
        val
    end
  end
end
