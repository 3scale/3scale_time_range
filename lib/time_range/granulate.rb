class TimeRange < Range
  class Granulate
    attr_accessor :days, :months, :years, :rest

    def initialize(range)
      raise 'Supports only TimeRange objects' unless range.is_a? TimeRange

      @days = []
      @years = []
      @months = []
      @rest = []
      split range
    end

    private

    def split(range)
      extract_cycle(range, :year)
    end

    def extract_cycle(range, cycle)
      @rest << range and return if cycle.nil?

      cycle_start, cycle_end = extract_cycle_boundaries(range, cycle)
      if cycle_start && cycle_end
        instance_variable_get("@#{cycle}s") << TimeRange.new(cycle_start, cycle_end)

        if range.begin < cycle_start
          extract_cycle(TimeRange.new(range.begin,
            (cycle_start - 1.hour).end_of_day), next_cycle(cycle))
        end
        if range.end > cycle_end
          extract_cycle(TimeRange.new(
             (cycle_end + 1.hour).beginning_of_day, range.end), next_cycle(cycle))
        end
      else
        extract_cycle(range, next_cycle(cycle))
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

    def extract_cycle_boundaries(range, cycle)
      result = []
      range.each(cycle) do |date|
        if date.send("beginning_of_#{cycle}") >= range.begin &&
          date.send("end_of_#{cycle}") <= range.end
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

  end
end
