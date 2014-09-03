class TimeRange < Range
  class Granulate
    attr_accessor :days, :months, :years, :rest

    def initialize(range)
      raise 'Supports only TimeRange objects' unless range.is_a? TimeRange

      @days = []
      @years = []
      @months = []
      @rest = []
      split(range)
    end

    private

    def split(range)
      extract_years(range)
    end

    def extract_years(range)
      result = []
      range.each(:year) do |year|
        if year.beginning_of_year >= range.begin && year.end_of_year <= range.end
          result << year
        end
      end
      @years << TimeRange.new(result.first.beginning_of_year, result.last.end_of_year)

      if range.begin < result.first.beginning_of_year
        extract_months(TimeRange.new(range.begin,
          (result.first.beginning_of_year - 1.day).end_of_month))
      end
      if range.end > result.last.end_of_year
        extract_months(TimeRange.new(
           (result.last.end_of_year + 1.day).beginning_of_month, range.end))
      end
    end

    def extract_months(range)
      result = []
      range.each(:month) do |month|
        if month.beginning_of_month >= range.begin && month.end_of_month <= range.end
          result << month
        end
      end
      @months << TimeRange.new(result.first.beginning_of_month, result.last.end_of_month)

      if range.begin < result.first.beginning_of_month
        extract_days(TimeRange.new(range.begin,
          (result.first.beginning_of_month - 1.hour).end_of_day))
      end
      if range.end > result.last.end_of_month
        extract_days(TimeRange.new(
           (result.last.end_of_month + 1.hour).beginning_of_day, range.end))
      end
    end

    def extract_days(range)
      result = []
      range.each(:day) do |day|
        if day.beginning_of_day >= range.begin && day.end_of_day <= range.end
          result << day
        end
      end
      @days << TimeRange.new(result.first.beginning_of_day, result.last.end_of_day)

      if range.begin < result.first.beginning_of_day
        @rest << TimeRange.new(range.begin,
          (result.first.beginning_of_day - 1.hour).end_of_day)
      end
      if range.end > result.last.end_of_day
        @rest << TimeRange.new(
           (result.last.end_of_day + 1.hour).beginning_of_day, range.end)
      end
    end

  end
end
