defmodule Core.Dataset.ParseHelpers do
  def merge(enum1, enum2, fun) when length(enum1) == length(enum2) do
    {:ok, do_merge(enum1, enum2, fun, [])}
  end

  def merge(e1, e2, _) do
    {:error, "Size Mismatch: Enum1: #{inspect(e1)}\nEnum2: #{inspect(e2)}"}
  end

  defp do_merge([], [], _fun, acc) do
    Enum.reverse(acc)
  end

  defp do_merge(enum1, enum2, fun, acc) do
    [h1 | t1] = enum1
    [h2 | t2] = enum2

    do_merge(t1, t2, fun, [fun.(h1, h2) | acc])
  end

  def type(nil, _type), do: nil

  def type(str, type) do
    parse =
      case type do
        :float ->
          Float.parse(str)

        :int ->
          IO.inspect(is_bitstring(str))
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
