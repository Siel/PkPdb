defmodule Core.Dataset.Nonmem.Parse do
  @moduledoc false

  #  alias(NimbleCSV.RFC4180, as: Nimble)
  import Core.Dataset.ParseHelpers, only: [merge: 3, type: 2]

  def parse_events(str) do
    with {:ok, headers, cov_headers} <- parse_headers(str),
         {:ok, events} <- merge_events(headers, str),
         {:ok, parsed_events} <- map_nonmem(events, cov_headers) do
      {:ok, parsed_events}
    else
      {:error, error} ->
        {:error, error}
    end
  end

  defp merge_events(headers, str) do
    [_headers | events] =
      str
      |> String.trim_trailing()
      |> String.split("\n")

    events =
      events
      |> Enum.map(fn row -> String.split(row, ",") end)
      |> Enum.map(&merge(headers, &1, fn x, y -> {x, y} end))
      |> Enum.map(fn row ->
        case row do
          {:ok, val} ->
            val
            |> Enum.into(%{})

          {:error, error} ->
            raise("Error: Parsing error: #{error}")
        end
      end)

    {:ok, events}
  end

  defp parse_headers(str) do
    [headers | _events] =
      str
      |> String.split("\n")

    headers =
      headers
      |> String.split(",")
      |> Enum.map(&String.to_atom/1)

    cov_headers =
      headers
      |> Enum.drop(10)

    cond do
      not valid_headers?(headers) ->
        {:error, "Invalid header format"}

      true ->
        {:ok, headers, cov_headers}
    end
  end

  defp map_nonmem(events, cov_headers) do
    {:ok,
     events
     |> Enum.map(&do_map_nonmem(&1, cov_headers))}
  end

  defp do_map_nonmem(
         %{
           id: id,
           addl: addl,
           amt: amt,
           cmt: cmt,
           dv: dv,
           evid: evid,
           ii: ii,
           mdv: mdv,
           rate: rate,
           ss: ss,
           time: time
         } = event,
         cov_headers
       ) do
    cov =
      cov_headers
      |> Enum.map(fn key -> {key, event[key]} end)
      |> Enum.into(%{})

    %{
      subject: id,
      addl: addl |> type(:int),
      amt: amt |> type(:float),
      cmt: cmt |> type(:int),
      dv: dv |> type(:float),
      evid: evid |> type(:int),
      ii: ii |> type(:float),
      mdv: mdv |> type(:int),
      rate: rate |> type(:float),
      ss: ss |> type(:int),
      time: time |> type(:float),
      cov: cov
    }
  end

  defp valid_headers?(headers) do
    length(
      headers
      |> Enum.uniq()
      |> Enum.filter(fn x ->
        x in [:addl, :amt, :cmt, :dv, :evid, :ii, :mdv, :rate, :ss, :time]
      end)
    ) == 10
  end
end
