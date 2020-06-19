require 'benchmark/ips'
require 'active_support/dependencies/autoload'
require 'active_support/deprecation'
require 'active_support/core_ext'
require_relative '../../lib/3scale_time_range'
require 'pry'


Time.zone = 'Eastern Time (US & Canada)'

start_time = Time.new(2014, 6, 1)
end_time = Time.new(2014, 6, 2)

start_time_with_zone = start_time.in_time_zone
end_time_with_zone = end_time.in_time_zone

period_with_zone = TimeRange.new(start_time_with_zone, end_time_with_zone)

class GCSuite
  def warming(*)
    run_gc
  end

  def running(*)
    run_gc
  end

  def warmup_stats(*)
  end

  def add_report(*)
  end

  private

  def run_gc
    GC.enable
    GC.start
    GC.disable
  end
end

class SimpleEnumeratorWithTimeZone
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

class SimpleEnumeratorWithTime
  include Enumerable

  def initialize(range, step)
    @range = range
    @step  = step.is_a?(Symbol) ? 1.send(step) : step
  end

  def each
    offset  = @range.utc_offset
    current = @range.begin.utc + offset
    last    = @range.end.utc.to_i + offset
    last   -= @step if @range.exclude_end?

    while current.to_i <= last
      yield(current)
      current += @step
    end

    self
  end
end

Benchmark.ips do |x|
  x.config(suite: GCSuite.new)

  x.report('time with zone objects') do
    SimpleEnumeratorWithTimeZone.new(period_with_zone, :hour).each { }
  end

  x.report('basic time objects') do
    SimpleEnumeratorWithTime.new(period_with_zone, :hour).each { }
  end

  x.compare!
end
