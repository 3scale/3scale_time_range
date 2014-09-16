class TimeRange
  class Granulate
    attr_accessor :days, :months, :years, :rest

    def initialize(range)
      raise 'Supports only TimeRange objects' unless range.is_a? TimeRange

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
          extract(
            TimeRange.new(range.begin, (cycle_start - 1.hour).end_of_day, false),
            next_cycle(cycle)
          )
        end
        if range.end > cycle_end
          extract(
            TimeRange.new(
              (cycle_end + 1.hour).beginning_of_day, range.end, range.exclude_end?
            ),
            next_cycle(cycle)
          )
        end
      else
        extract(range, next_cycle(cycle))
      end
    end

    def next_cycle(current_cycle)
      case current_cycle
        when :year then :month
        when :month then :day
        when :day then nil
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
        (value < range.end || (value == range.end && !range.exclude_end?))
    end

    # TODO: Can be refactored to TimeRange#empty?
    # Refactoring requires investigation into TimeRange use in System.
    def empty_range?(range)
      (range.begin == range.end) && range.exclude_end?
    end

  end
end
