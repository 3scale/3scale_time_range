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

period = TimeRange.new(start_time, end_time)
period_with_zone = TimeRange.new(start_time_with_zone, end_time_with_zone)

range = (start_time.to_i .. end_time.to_i)
range_with_zone = (start_time_with_zone.to_i .. end_time_with_zone.to_i )

one_hour = 1.hour

zone = start_time_with_zone.time_zone

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

class TestCase
  attr_reader :name, :to_proc

  def initialize(*)
    @proc = block_given? ? Proc.new : Proc.new{}
  end

  def to_ary
    [name, to_proc]
  end

  alias to_a to_ary
end



class PeriodTest < TestCase
  def initialize(period)
    super()
    @period = period
    @name = 'period'
  end

  def to_proc
    proc {
      @period.each(:hour) { }
    }
  end
end

class PeriodWithZoneTest < PeriodTest
  def initialize(period)
    super(period)
    @name = 'period with zone'
  end
end

class RangeTest < TestCase
  def initialize(range)
    super
    @range = range
    @name = 'range'
  end

  def to_proc
    one_hour = 1.hour
    proc {
      @range.step(one_hour) { |i| Time.at(i) }
    }
  end
end

class RangeWithZoneTest < RangeTest

  def initialize(range)
    super
    @name = 'range with zone'
  end

  def to_proc
    one_hour = 1.hour
    zone = Time.zone

    proc {
      @range.step(one_hour) { |i| zone.at(i) }
    }
  end
end

Benchmark.ips do |x|
  x.config(suite: GCSuite.new)

  x.report(*PeriodWithZoneTest.new(period_with_zone))
  x.report(*PeriodTest.new(period))

  x.report(*RangeTest.new(range))
  x.report(*RangeWithZoneTest.new(range_with_zone))

  x.report('while') do

    time = start_time_with_zone.to_i

    values = []

    Time.use_zone(zone) do
      end_i = end_time_with_zone.to_i

      while time < end_i do
        foo = Time.zone.at(time)
        values << foo
        time = (foo + one_hour).to_i
      end
    end
  end

  x.compare!
end


Benchmark.ips do |x|
  x.config(suite: GCSuite.new)

  x.report('time.at') do
    Time.at(1401573600)
  end

  zone = Time.zone
  x.report('zone.at') do
    zone.at(1401573600)
  end

  x.compare!
end
