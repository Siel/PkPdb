defmodule Core.Dataset.Nonmem.Parse do
  @moduledoc false

  #  alias(NimbleCSV.RFC4180, as: Nimble)
  import Core.Dataset.ParseHelpers, only: [merge: 3, type: 2]

  @required_headers [:id, :time, :amt, :dv]
  @optional_headers [:rate, :mdv, :evid, :cmt, :ss, :addl, :ii]

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

  defp parse_headers(str) do
    [headers | _events] =
      str
      |> String.split("\n")

    headers =
      headers
      |> String.split(",")
      |> Enum.map(&(String.downcase(&1) |> String.to_atom()))

    # |> Enum.drop(10)
    cov_headers = (headers -- @required_headers) -- @optional_headers

    cond do
      not valid_headers?(headers) ->
        {:error, "Invalid header format"}

      true ->
        {:ok, headers, cov_headers}
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

  defp map_nonmem(events, cov_headers) do
    {:ok,
     events
     |> Enum.map(&do_map_nonmem(&1, cov_headers))}
  end

  defp do_map_nonmem(
         %{
           id: id,
           time: time,
           amt: amt,
           dv: dv
         } = event,
         cov_headers
       ) do
    # TODO: Look for the default values for these keys
    cmt = event.cmt
    addl = event.addl
    evid = event.evid
    ii = event.ii
    mdv = event.mdv
    rate = event.rate
    ss = event.ss

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
    Enum.all?(@required_headers, fn req -> req in headers end)

    # length(
    #   headers
    #   |> Enum.uniq()
    #   |> Enum.filter(fn x ->
    #     x in [:addl, :amt, :cmt, :dv, :evid, :ii, :mdv, :rate, :ss, :time]
    #   end)
    # ) == 10
  end
end
