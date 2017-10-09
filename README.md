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


Version compatibility
--------
0.3.0: Public repository along with the very first RubyGems gem

0.2.0: The Granulate class has been converted to a class method that returns a
hash. Granulate was not easy to use because it returned an instance of
'Granulate'. This prevented clients from iterating through the result.

0.1.0: breaks compatibility with previous versions because it adds hours to the
Granulate class. This means that in previous versions Granulate.rest contained
time ranges that cannot be separated into days when granulating, but now it
just contains ranges that cannot be separated into hours.



