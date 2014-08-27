require 'minitest/autorun'
require_relative '../lib/time_range'

class TimeRangeTest < Minitest::Test

  def test_is_creatable_only_from_Times
    assert_raises(ArgumentError) { TimeRange.new(:foo, :bar) }
    assert_raises(ArgumentError) { TimeRange.new(400, 700) }
  end

  def test_converts_from_Range_only_if_extremes_are_Time_instances
    assert_raises(ArgumentError) { (100..300).to_time_range }
    assert_instance_of TimeRange, (Time.local(2009, 3, 2)..Time.local(2009, 3, 11)).to_time_range
  end

  def test_enumerates_with_symbol
    stuff = []
    period = (Time.local(2009, 3, 2)..Time.local(2009, 3, 4)).to_time_range

    period.each(:day) { |time| stuff << time }

    assert_equal [Time.local(2009, 3, 2), Time.local(2009, 3, 3), Time.local(2009, 3, 4)],
                 stuff
  end

  def test_enumerates_with_custom_step
    stuff = []
    period = (Time.local(2009, 3, 2)..Time.local(2009, 3, 3)).to_time_range

    period.each(12.hours) { |time| stuff << time }

    assert_equal [Time.local(2009, 3, 2, 00, 00), Time.local(2009, 3, 2, 12, 00), Time.local(2009, 3, 3, 00, 00)], stuff
  end

  def test_returns_enumerator_on_each
    period = (Time.local(2009, 3, 2)..Time.local(2009, 3, 3)).to_time_range
    days = period.each(:day).map { |time| time }

    assert_equal [Time.local(2009, 3, 2), Time.local(2009, 3, 3)], days
  end

  def test_excludes_end_if_exclusive
    period = TimeRange.new(Time.local(2009, 3, 2), Time.local(2009, 3, 4), true)
    days = period.each(:day).map { |time| time }

    assert_equal [Time.local(2009, 3, 2), Time.local(2009, 3, 3)], days
  end

  def test_enumerates_with_weekday
    period = (Time.local(2009, 11, 1)..Time.local(2009, 11, 30)).to_time_range

    assert_equal [Time.local(2009, 11,  2),
                  Time.local(2009, 11,  9),
                  Time.local(2009, 11, 16),
                  Time.local(2009, 11, 23),
                  Time.local(2009, 11, 30)], period.each(:monday).to_a

    assert_equal [Time.local(2009, 11,  3),
                  Time.local(2009, 11, 10),
                  Time.local(2009, 11, 17),
                  Time.local(2009, 11, 24)], period.each(:tuesday).to_a
  end

  def test_previous
    range    = TimeRange.new(Time.local(2009, 3, 2, 11, 33), Time.local(2009, 3, 2, 12, 33))
    expected = TimeRange.new(Time.local(2009, 3, 2, 10, 33), Time.local(2009, 3, 2, 11, 33), true)

    assert_equal expected, range.previous
  end

  def test_add_and_or_substract_interval
    range    = TimeRange.new(Time.local(2009, 3, 2, 11, 00), Time.local(2009, 3, 2, 12, 00))
    expected = TimeRange.new(Time.local(2009, 3, 2, 13, 00), Time.local(2009, 3, 2, 14, 00))
    assert_equal expected, range + 2.hours
    assert_equal range, (range + 2.hours) - 2.hours
  end

  def test_month_returns_true_if_the_range_is_whole_month
    time  = Time.local(2010, 11, 1)
    range = TimeRange.new(time.beginning_of_month, time.end_of_month)

    assert range.month?
  end

  def test_month_return_fals_if_the_range_is_not_whole_month
    range = TimeRange.new(Time.local(2010, 11, 6), Time.local(2010, 11, 17))

    assert !range.month?
  end

  def test_month_returns_false_if_the_begin_and_end_are_in_different_months
    range = TimeRange.new(Time.local(2010, 10, 1), Time.local(2010, 11, 30).end_of_month)

    assert !range.month?
  end

  def test_month_returns_false_if_the_begin_and_end_are_in_the_same_month_but_different_years
    range = TimeRange.new(Time.local(2010, 11, 1), Time.local(2011, 11, 30).end_of_month)

    assert !range.month?
  end
end

