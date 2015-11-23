require 'minitest/autorun'
require_relative '../lib/3scale_time_range'

class GranulateTest < Minitest::Test

  def setup
    range = DateTime.parse('2012-10-09 07:23')..DateTime.parse('2014-02-05 13:45')
    @granulated_range = TimeRange.granulate(range)
  end

  def test_granulates_by_year
    assert_equal @granulated_range[:years],
                 [TimeRange.new(
                     DateTime.parse("2013-01-01").beginning_of_year,
                     DateTime.parse("2013-12-31").end_of_year)]
  end

  def test_granulates_by_month
    assert_equal @granulated_range[:months],
                 [TimeRange.new(
                     DateTime.parse("2012-11-01").beginning_of_month,
                     DateTime.parse("2012-12-31").end_of_month),
                  TimeRange.new(
                      DateTime.parse("2014-01-01").beginning_of_month,
                      DateTime.parse("2014-01-31").end_of_month)]
  end


  def test_granulates_by_day
    assert_equal @granulated_range[:days],
                 [TimeRange.new(
                     DateTime.parse("2012-10-10").beginning_of_day,
                     DateTime.parse("2012-10-31").end_of_day),
                  TimeRange.new(
                      DateTime.parse("2014-02-01").beginning_of_day,
                      DateTime.parse("2014-02-04").end_of_day)]
  end

  def test_granulates_by_hour
    assert_equal @granulated_range[:hours],
                 [TimeRange.new(
                     DateTime.parse("2012-10-09 08:00").beginning_of_hour,
                     DateTime.parse("2012-10-09 23:00").end_of_hour),
                  TimeRange.new(
                      DateTime.parse("2014-02-05 00:00").beginning_of_hour,
                      DateTime.parse("2014-02-05 12:00").end_of_hour)]
  end

  def test_exposes_information_on_not_granulated_ranges
    assert_equal @granulated_range[:rest],
                 [TimeRange.new(
                     DateTime.parse("2012-10-09 07:23"),
                     DateTime.parse("2012-10-09 07:00").end_of_hour),
                  TimeRange.new(
                      DateTime.parse("2014-02-05 13:45").beginning_of_hour,
                      DateTime.parse("2014-02-05 13:45"))]
  end

  def test_range_that_cannot_be_granulated
    granulated_range = TimeRange.granulate(
        DateTime.parse("2012-10-09 07:23")..DateTime.parse("2012-10-09 07:45"))

    assert_equal granulated_range[:rest],
                 [TimeRange.new(
                     DateTime.parse("2012-10-09 07:23"),
                     DateTime.parse("2012-10-09 07:45"))]
  end

  def test_properly_parses_open_ended_ranges_1
    granulated_range = TimeRange.granulate(
        DateTime.parse("2011-01-01")...DateTime.parse("2012-01-01"))

    assert_equal 1, granulated_range[:years].size
    assert_equal 0, granulated_range[:months].size
    assert_equal 0, granulated_range[:days].size
    assert_equal 0, granulated_range[:hours].size
    assert_equal 0, granulated_range[:rest].size

    refute granulated_range[:years].first.exclude_end?
  end

  def test_properly_parses_open_ended_ranges_2
    granulated_range = TimeRange.granulate(
        DateTime.parse("2011-01-01")...DateTime.parse("2011-12-31").end_of_year)

    assert_equal 0, granulated_range[:years].size
    assert_equal 1, granulated_range[:months].size
    assert_equal 1, granulated_range[:days].size
    assert_equal 1, granulated_range[:hours].size
    assert_equal 1, granulated_range[:rest].size

    refute granulated_range[:hours].first.exclude_end?
    refute granulated_range[:months].first.exclude_end?
    refute granulated_range[:days].first.exclude_end?
    assert granulated_range[:rest].first.exclude_end?
  end

  def test_properly_parses_close_ended_ranges_1
    granulated_range = TimeRange.granulate(
        DateTime.parse("2011-01-01")..DateTime.parse("2012-01-01"))

    assert_equal 1, granulated_range[:years].size
    assert_equal 0, granulated_range[:months].size
    assert_equal 0, granulated_range[:days].size
    assert_equal 0, granulated_range[:hours].size
    assert_equal 1, granulated_range[:rest].size

    refute granulated_range[:rest].first.exclude_end?
  end

  def test_properly_parses_close_ended_ranges_2
    granulated_range = TimeRange.granulate(
        DateTime.parse("2011-01-01")..DateTime.parse("2011-12-31").end_of_year)

    assert_equal 1, granulated_range[:years].size
    assert_equal 0, granulated_range[:months].size
    assert_equal 0, granulated_range[:days].size
    assert_equal 0, granulated_range[:hours].size
    assert_equal 0, granulated_range[:rest].size

    refute granulated_range[:years].first.exclude_end?
  end

  def test_properly_handles_Time_UTC_ends_of_months
    d = DateTime.parse('2010-01-01')
    granulated_range = TimeRange.granulate(
        d.beginning_of_month.to_time.utc..d.end_of_month.to_time.utc)

    assert_equal 0, granulated_range[:years].size
    assert_equal 1, granulated_range[:months].size
    assert_equal 0, granulated_range[:days].size
    assert_equal 0, granulated_range[:hours].size
    assert_equal 0, granulated_range[:rest].size
  end

end

