class TimeRange
  class Granulate
    attr_accessor :hours, :days, :months, :years, :rest

    def initialize(range)
      raise 'Supports only TimeRange objects' unless range.is_a? TimeRange

      @hours = []
      @days = []
      @years = []
      @months = []
      @rest = []
      extract(range, :year)
    end

    private

    def extract(range, cycle)
      if cycle.nil?
        rest << range unless empty_range?(range)
        return
      end

      cycle_start, cycle_end = extract_boundaries(range, cycle)
      if cycle_start && cycle_end
        send("#{cycle}s") << TimeRange.new(cycle_start, cycle_end)

        if range.begin < cycle_start
          # Getting the last hour is enough because is the smallest resolution
          # that we support. If we supported minutes, we would need to get the
          # last minute non included.
          last_hour_not_treated = (cycle_start - 1.hour).end_of_hour
          extract(
            TimeRange.new(range.begin, last_hour_not_treated, false),
            next_cycle(cycle))
        end

        if range.end > cycle_end
          first_hour_not_treated = (cycle_end + 1.hour).beginning_of_hour
          extract(
            TimeRange.new(first_hour_not_treated, range.end, range.exclude_end?),
            next_cycle(cycle))
        end
      else
        extract(range, next_cycle(cycle))
      end
    end

    def next_cycle(current_cycle)
      case current_cycle
        when :year then :month
        when :month then :day
        when :day then :hour
        when :hour then nil
        else raise "Unknown cycle: #{current_cycle.inspect}"
      end
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
