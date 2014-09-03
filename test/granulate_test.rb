require 'minitest/autorun'
require_relative '../lib/time_range'

class GranulateTest < Minitest::Test

  def setup
    range = TimeRange.new(
      DateTime.parse("2012-10-09 07:23"), DateTime.parse("2014-02-05 13:45"))
    @gran = range.granulate
  end

  def test_granulates_by_year
    assert_equal @gran.years, [
      TimeRange.new(
        DateTime.parse("2013-01-01").beginning_of_year,
        DateTime.parse("2013-12-31").end_of_year)
    ]
  end

  def test_granulates_by_month
    assert_equal @gran.months, [
        TimeRange.new(
          DateTime.parse("2012-11-01").beginning_of_month,
          DateTime.parse("2012-12-31").end_of_month),

        TimeRange.new(
          DateTime.parse("2014-01-01").beginning_of_month,
          DateTime.parse("2014-01-31").end_of_month)
      ]
  end

  def test_granulates_by_day
    assert_equal @gran.days, [
        TimeRange.new(
          DateTime.parse("2012-10-10").beginning_of_day,
          DateTime.parse("2012-10-31").end_of_day),

        TimeRange.new(
          DateTime.parse("2014-02-01").beginning_of_day,
          DateTime.parse("2014-02-04").end_of_day)
      ]
  end

  def test_exposes_information_on_not_granulated_ranges
    assert_equal @gran.rest, [
        TimeRange.new(
          DateTime.parse("2012-10-09 07:23"),
          DateTime.parse("2012-10-09").end_of_day),

        TimeRange.new(
          DateTime.parse("2014-02-05").beginning_of_day,
          DateTime.parse("2014-02-05 13:45"))
      ]
  end
end


