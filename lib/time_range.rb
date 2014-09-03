require 'time_range/version'
require 'active_support/time'

require_relative 'time_range/granulate'

class TimeRange < Range

  def initialize(start_time, end_time, exclusive = false)
    raise ArgumentError, 'start and end must act like Time' unless start_time.acts_like?(:time) && end_time.acts_like?(:time)

    super
  end

  WEEKDAYS = {:monday    => 0,
              :tuesday   => 1,
              :wednesday => 2,
              :thursday  => 3,
              :friday    => 4,
              :saturday  => 5,
              :sunday    => 6}

  def each(step = nil, &block)
    if step
      enumerator = if WEEKDAYS[step]
                     WeekdayEnumerator
                   elsif step == :end_of_month # the simple enumerator already works for the beginning, every month has a 1st
                     MonthEnumerator
                   else
                     SimpleEnumerator
                   end.new(self, step)

      enumerator.each(&block) if block_given?
      enumerator
    else
      super
    end
  end

  # Shifts the time range to given timezone via Time#in_time_zone method.
  def in_time_zone(timezone)
    TimeRange.new(self.begin.in_time_zone(timezone), self.end.in_time_zone(timezone))
  end

  def +(interval)
    # TODO - check it
    # raise ArgumentError.new('Only Fixnum is allowed') unless Fixnum === interval
    TimeRange.new(self.begin + interval, self.end + interval)
  end

  def -(interval)
    self + (-interval)
  end

  def utc
    self.in_time_zone('UTC')
  end

  # TODO: TimeRange should check if both 'begin' and 'end' are in
  # the same timezone?
  def zone
    assert_time_with_zone
    self.begin.zone
  end

  def utc_offset
    assert_time_with_zone
    self.begin.utc_offset
  end

  def shift_in_hours
    self.utc_offset / 3600
  end


  def assert_time_with_zone
    raise TypeError.new('Has to be TimeWithZone') unless ActiveSupport::TimeWithZone === self.begin
  end

  private :assert_time_with_zone

  def length
    self.end - self.begin
  end

  # "round" range, so it starts at the beginning of the cycle and end at it's end.
  # TODO: maybe round is not the best name for this method.
  def round(cycle)
    self.class.new(self.begin.beginning_of_cycle(cycle),
                   self.end.end_of_cycle(cycle))
  end

  # Previous time range, that is, a range with the same length as this range, but which
  # ends when this range starts. Excludes the last element.
  def previous
    self.class.new(self.begin - length, self.begin, true)
  end

  def to_time_range
    self
  end

  def to_s
    "#{self.begin.strftime("%B %e, %Y (%k:%M)")} - #{self.end.strftime("%B %e, %Y (%k:%M)")}"
  end

 # Does this range cover a whole month?
  def month?
    self.begin.year == self.end.year &&
    self.begin.month == self.end.month &&
    self.begin == self.begin.beginning_of_month &&
    self.end == self.end.end_of_month
  end

  def inspect
    "#{self.class.name}(#{super})"
  end

  def granulate
    Granulate.new(self)
  end

  class SimpleEnumerator
    include Enumerable

    def initialize(range, step)
      @range, @step = range, step.is_a?(Symbol) ? 1.send(step) : step
    end

    def each
      current = @range.begin
      last = @range.end
      last -= @step if @range.exclude_end?

      while current.to_i <= last.to_i
        yield(current)
        current += @step
      end

      self
    end
  end

  class WeekdayEnumerator
    include Enumerable

    def initialize(range, weekday)
      @range, @offset = range, WEEKDAYS[weekday].days
    end

    def each
      current = @range.begin.beginning_of_week + @offset
      current = current + 1.week if current < @range.begin
      last    = @range.end

      while current <= last
        yield(current)
        current += 1.week
      end

      self
    end
  end

  class MonthEnumerator
    include Enumerable

    def initialize(range, step)
      @range = range
    end

    def each
      current = @range.begin
      last = @range.end
      last -= 1.month if @range.exclude_end?

      while current <= last
        yield(current)
        current = (current + 1.month).end_of_month
      end

      self
    end
  end
end

class Range
  def to_time_range
    TimeRange.new(self.begin, self.end, self.exclude_end?)
  end
end

