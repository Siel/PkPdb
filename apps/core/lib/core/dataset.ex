defmodule Core.Dataset do
  @moduledoc """
  Dataset API Layer
  A Dataset is an abstraction of a set of events, its fuctionality is to:
  -Decode events
  -Store events
  -Validate events
  -Transform events from one format to other
  """
  alias __MODULE__
  @enforce_keys [:valid, :share, :name]
  defstruct [
    :name,
    :description,
    :citation,
    :share,
    :type,
    :original_type,
    :valid,
    :warnings,
    :inserted_at,
    :updated_at
    # :event,
    # :owner,
    # :tags
  ]
end
