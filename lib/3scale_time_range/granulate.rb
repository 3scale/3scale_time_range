module Granulate
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    GRANULARITIES = [:year, :month, :day, :hour]

    def granulate(range)
      result = { rest: [] }
      GRANULARITIES.each do |granularity|
        result[(granularity.to_s + 's').to_sym] = []
      end
      time_range = TimeRange.new(range.begin, range.end, range.exclude_end?)
      extract(time_range, GRANULARITIES.first, result)
      result
    end

    private

    def extract(range, cycle, result)
      if cycle.nil?
        result[:rest] << range unless empty_range?(range)
        return
      end

      cycle_start, cycle_end = extract_boundaries(range, cycle)
      if cycle_start && cycle_end
        result[(cycle.to_s + 's').to_sym] << TimeRange.new(cycle_start, cycle_end)

        if range.begin < cycle_start
          # Getting the last hour is enough because is the smallest resolution
          # that we support. If we supported minutes, we would need to get the
          # last minute non included.
          last_hour_not_treated = (cycle_start - 1.hour).end_of_hour
          extract(TimeRange.new(range.begin, last_hour_not_treated, false),
                  next_cycle(cycle),
                  result)
        end

        if range.end > cycle_end
          first_hour_not_treated = (cycle_end + 1.hour).beginning_of_hour
          extract(TimeRange.new(first_hour_not_treated, range.end, range.exclude_end?),
                  next_cycle(cycle),
                  result)
        end
      else
        extract(range, next_cycle(cycle), result)
      end
    end

    def next_cycle(current_cycle)
      current_cycle_index = GRANULARITIES.find_index(current_cycle)
      raise "Unknown cycle: #{current_cycle.inspect}" unless current_cycle_index
      GRANULARITIES[current_cycle_index + 1]
    end

    def extract_boundaries(range, cycle)
      result = []
      range.each(cycle) do |date|
        if included_in_range?(range, date.send("beginning_of_#{cycle}")) &&
            included_in_range?(range, date.send("end_of_#{cycle}"))
          result << date
        end
      end
      if result.empty?
        return nil, nil
      else
        return result.first.send("beginning_of_#{cycle}"),
          result.last.send("end_of_#{cycle}")
      end
    end

    # TODO: Can be refactored to TimeRange#include?
    # Refactoring requires investigation into TimeRange use in System.
    def included_in_range?(range, value)
      (range.begin <= value) &&
        (value < range.end || (value.to_i == range.end.to_i && !range.exclude_end?))
    end

    # TODO: Can be refactored to TimeRange#empty?
    # Refactoring requires investigation into TimeRange use in System.
    def empty_range?(range)
      (range.begin.to_i == range.end.to_i) && range.exclude_end?
    end
  end
end
