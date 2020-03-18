defmodule Core.Pmetrics.Transform do
  alias Core.Pmetrics

  def to(%Pmetrics.Event{}, "nonmem") do
  end

  def to(%Pmetrics.Event{}, _) do
    raise "Error. Unimplemented transformation"
  end
end
