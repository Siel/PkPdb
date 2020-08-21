defmodule Core.Dataset.Nonmem.Transform do
  @moduledoc false

  def set_to(%Core.Dataset{} = dataset, "pmetrics") do
    dataset
  end

  def event_to({event, index}, "pmetrics") do
    calc_evid = fn evid ->
      if evid in [2, 3],
        do: {nil, "E-Line#{index}: evid = #{evid} not supported in pmetrics"},
        else: evid
    end

    calc_dur = fn event ->
      if event.evid == 1 do
        if(event.rate == 0 or is_nil(event.rate), do: 0, else: event.amt / event.rate)
      else
        nil
      end
    end

    calc_input = fn event ->
      if event.evid == 1,
        do: {event.cmt, "W-Line#{index}: input set to Nonmem's cmt this might not be true."},
        else: nil
    end

    calc_outeq = fn event ->
      if event.evid == 0,
        do: {event.cmt, "W-Line#{index}: outeq set to Nonmem's cmt this might not be true."},
        else: nil
    end

    %{
      subject: "#{event.subject}",
      evid: calc_evid.(event.evid),
      time: event.time,
      dur: calc_dur.(event),
      dose: event.amt,
      addl: if(event.ss == 1, do: -1, else: event.addl),
      ii: event.ii,
      input: calc_input.(event),
      out: if(event.mdv == 1, do: -99, else: event.dv),
      outeq: calc_outeq.(event),
      c0: nil,
      c1: nil,
      c2: nil,
      c3: nil,
      cov: event.cov
    }
  end
end
