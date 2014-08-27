Utility class for ranges of times (time periods). It's like Range, but has
additional enumeration capabilities. See examples for the tasty stuff.

Examples
--------

    period = TimeRange.new(1.year.ago, Time.now)

Enumerate by days

    period.each(:day) { |time| puts time }

Enumerate by weeks

    period.each(:week) { |time| puts time }

(also years, months, hours, minutes and seconds)

Enumerate by custom period

    period.each(42.seconds) { |time| puts time }

+each+ Returns Enumerator object, so this is also possible (extra yummy):

    period.each(:month).map { |time| time.strftime('%B') }

Supports all Enumerable interface: find, select, reject, inject, etc.


