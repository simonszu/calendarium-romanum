# calendarium-romanum

[![Build Status](https://travis-ci.org/igneus/calendarium-romanum.svg?branch=master)](https://travis-ci.org/igneus/calendarium-romanum)
[![Gem Version](https://badge.fury.io/rb/calendarium-romanum.svg)](https://badge.fury.io/rb/calendarium-romanum)

[API documentation](http://www.rubydoc.info/github/igneus/calendarium-romanum/master)

Ruby gem for
calendar computations according to the Roman Catholic liturgical
calendar as instituted by
[MP Mysterii Paschalis](http://w2.vatican.va/content/paul-vi/en/motu_proprio/documents/hf_p-vi_motu-proprio_19690214_mysterii-paschalis.html) of Paul VI. (AAS 61 (1969), pp. 222-226).
The rules are defined in
*General Norms for the Liturgical Year and the Calendar*
([English translation][gnlyc]).

## Features

- [x] liturgical season
- [x] Sundays, temporale feasts
- [x] sanctorale calendars: data format, example data files, their loading
- [x] resolution of precedence of concurrent celebrations
- [x] octave days
- [x] commemorations in the privileged seasons where memorials are suppressed
- [x] transfer of suppressed solemnities
- [x] optional transfer of important solemnities to a Sunday
- [x] additional temporale feasts (Christ the Eternal Priest and similar)

## Credits

includes an important bit of code from the
[easter](https://github.com/jrobertson/easter) gem
by James Robertson

## License

freely choose between GNU/LGPL 3 and MIT

## Project status, Backward compatibility

The gem's public interface still evolves and each minor release
contains several breaking changes. There is no backward compatibility
between minor versions.
This will continue until release of v1.0.0.

When using the gem in your projects, it is recommended to lock
the dependency to a particular minor version.

In your app's Gemfile

```
gem 'calendarium-romanum', '~>0.3.0'
```

or in gemspec of your gem

```
spec.add_dependency 'calendarium-romanum', '~>0.3.0'
```

## Basic Usage

For more self-explaining, commented and copy-pastable
examples see the [examples directory](./examples/).

All the examples below expect that you first required the gem:

```ruby
require 'calendarium-romanum'
```

### 1. What liturgical season is it today?

```ruby
calendar = CalendariumRomanum::Calendar.for_day(Date.today)
day = calendar.day(Date.today)
day.season # => #<CalendariumRomanum::Season:0x000000029e1a40 @symbol=:ordinary, @colour=#<CalendariumRomanum::Colour:0x000000029e1f68 @symbol=:green>>
```

`Day#season` returns a `Season` instance representing
the current liturgical season.

### 2. What liturgical day is it today?

`Day` has several other properties.
`Day#celebrations` returns an `Array` of `Celebration`s
that occur on the given day. Usually the `Array` has a single
element, but in case of optional celebrations (several optional
memorials occurring on a ferial) it may have two or more.

```ruby
date = Date.new(2016, 8, 19)
calendar = CalendariumRomanum::Calendar.for_day(date)
day = calendar.day(date)
day.celebrations # => [#<CalendariumRomanum::Celebration:0x0000000250fdf0 @title="Friday, 20th week in Ordinary Time", @rank=#<CalendariumRomanum::Rank:0x000000029e1108 @priority=3.13, ... >, @colour=#<CalendariumRomanum::Colour:0x000000029e1f68 @symbol=:green>>]
```

In this case the single `Celebration` available is a ferial,
described by it's title, rank and liturgical
colour.

### 3. But does it take feasts of saints in account?

Actually, no. Not yet. We need to load some calendar data first:

```ruby
CR = CalendariumRomanum
loader = CR::SanctoraleLoader.new
sanctorale = loader.load_from_file 'data/universal-en.txt' # insert path to your data file
date = Date.new(2016, 8, 19)
calendar = CR::Calendar.for_day(date, sanctorale)
day = calendar.day(date)
day.celebrations # => [#<CalendariumRomanum::Celebration:0x000000027d9590 @title="Friday, 20th week in Ordinary Time", @rank=#<CalendariumRomanum::Rank:0x000000029e1108 @priority=3.13, ... >, @colour=#<CalendariumRomanum::Colour:0x000000029e1f68 @symbol=:green>>, #<CalendariumRomanum::Celebration:0x000000029c96c0 @title="Saint John Eudes, priest", @rank=#<CalendariumRomanum::Rank:0x000000029e1180 @priority=3.12, ... >, @colour=#<CalendariumRomanum::Colour:0x000000029e1f18 @symbol=:white>>]
```

(Note how we saved some typing by defining new constant `CR`
referencing the `CalendariumRomanum` module.)

Unless a sanctorale is loaded, `Calendar` only counts with
temporale feasts, Sundays and ferials.

### 4. Isn't there an easier way to get sanctorale data?

Yes! There are a few data files bundled in the gem.
You can explore them by iterating over `CalendariumRomanum::Data.all`.
The more interesting ones are additionally identified by their proper
constants, e.g. `CalendariumRomanum::Data::GENERAL_ROMAN_ENGLISH`.
Bundled data files can be loaded by a handy shortcut method `#load`:

```ruby
CR = CalendariumRomanum
sanctorale = CR::Data::GENERAL_ROMAN_ENGLISH.load # easy loading
date = Date.new(2016, 8, 19)
calendar = CR::Calendar.for_day(date, sanctorale)
day = calendar.day(date)
```

### 5. I don't want to care about (liturgical) years

Each Calendar instance is bound to a particular *liturgical* year.
Calling `Calendar#day` with a date out of the year's range
results in a `RangeError`:

```ruby
CR = CalendariumRomanum
calendar = CR::Calendar.new(2000)
begin
  day = calendar.day(Date.new(2000, 1, 1))
rescue RangeError
  # ouch
end
```

The example demonstrates the well known fact,
that the **civil and liturgical year don't match:**
1st January 2000
does not belong to the liturgical year 2000-2001
(which will begin on the first Sunday of Advent,
i.e. on 3rd December 2000), but to the year 1999-2000.
For the sake of simplicity, `calendarium-romanum` denotes
liturgical years by the starting year only, so you create
a `Calendar` for liturgical year 2000-2001 by calling
`Calendar.new(2000)`.

When you want to query a calendar without caring about liturgical
years, possibly picking days across multiple years,
the tool you are looking for is `PerpetualCalendar`.

```ruby
CR = CalendariumRomanum
pcal = CR::PerpetualCalendar.new

# get days
d1 = pcal.day(Date.new(2000, 1, 1))
d2 = pcal.day(Date.new(2100, 1, 1))
d3 = pcal.day(Date.new(1970, 1, 1))

# get Calendar instances if you need them
calendar = pcal.calendar_for_year(1987)
```

Just like `Calendar` with the default settings (no sanctorale data
etc.) is usually of little use, so is a `PerpetualCalendar`
creating such `Calendar`s. Of course it is possible to specify
configuration which is then applied on the `Calendar`s
being created:

```ruby
CR = CalendariumRomanum

pcal = CR::PerpetualCalendar.new(
  # Sanctorale instance
  sanctorale: CR::Data::GENERAL_ROMAN_ENGLISH.load,
  # options that will be passed to Temporale.new
  temporale_options: {
    transfer_to_sunday: [:epiphany],
    extensions: [CR::Temporale::Extensions::ChristEternalPriest]
  }
)
d = pcal.day(Date.new(2000, 1, 1))

# It is also possible to supply Temporale factory instead of options:
pcal = CR::PerpetualCalendar.new(
  # Proc returning a Temporale instance for the specified year
  temporale_factory: lambda do |year|
    CR::Temporale.new(year, transfer_to_sunday: [:ascension])
  end
)
pcal.day(Date.new(2000, 1, 1))
```

**Memory management note:**
By default, `PerpetualCalendar` caches each created `Calendar`
instance *perpetually.* This is OK in most cases,
but it can lead to memory exhaustion if you traverse an excessive
amount of liturgical years. In such cases you can supply
your own cache (a `Hash` or anything with hash-like interface)
and implement some kind of cache size limiting.

```ruby
CR = CalendariumRomanum
my_cache = {}
pcal = CR::PerpetualCalendar.new(cache: my_cache)
```

## Sanctorale Data

### Use prepared data or create your own

The gem expects data files following a custom format -
see README in the [data](/data) directory for it's description.
The same directory contains a bunch of example data files.
(All of them are also bundled in the gem and accessible via
`CalendariumRomanum::Data`, as described above.)

`universal-en.txt` and `universal-la.txt` are data of the General
Roman Calendar in English and Latin.

The `czech-*.txt` files, when layered properly, can be used to assemble
proper calendar of any diocese in the Czech Republic.

### Implement custom loading strategy

In case you already have sanctorale data in another format,
it might be better suited for you to implement your own loading
routine instead of migrating them to our custom format.
`SanctoraleLoader` is the class to look into for inspiration.

The important bit is that for each celebration you
build a `Celebration` instance and push it in a `Sanctorale`
instance by a call to `Sanctorale#add`, which receives a month,
a day (as integers) and a `Celebration`:

```ruby
include CalendariumRomanum
sanctorale = Sanctorale.new
celebration = Celebration.new('Saint John Eudes, priest', Ranks::MEMORIAL_OPTIONAL, Colours::WHITE)
sanctorale.add 8, 19, celebration

date = Date.new(2016, 8, 19)
calendar = Calendar.for_day(date, sanctorale)

day = calendar.day(date)
day.celebrations # => [#<CalendariumRomanum::Celebration:0x000000010deea8 @title="", @rank=#<struct CalendariumRomanum::Rank priority=3.13, desc="Unprivileged ferials", short_desc="ferial">, @colour=:green>, #<CalendariumRomanum::Celebration:0x000000010fec08 @title="Saint John Eudes, priest", @rank=#<struct CalendariumRomanum::Rank priority=3.12, desc="Optional memorials", short_desc="optional memorial">, @colour=:white>]
```

(Note that this time some typing was saved by *including*
the `CalendariumRomanum` module into the current namespace.)

## I18n, or, how to fix names of temporale feasts

One drawback of the current implementation is that names
of *temporale* feasts are totally independent of *sanctorale* feast
names. They are hardcoded in the gem, as [i18n][]
[translation strings][translations].

When you load *sanctorale* data in your favourite language,
the `Calendar` will by default still produce *temporale*
feasts with names in English.
This can be fixed by changing locale to match your *sanctorale*
data.

`I18n.locale = :la # or :it, :cs`

The gem ships with English, Latin, Italian, French and Czech translation.
Contributed translations to other languages are most welcome.

## Transfer of solemnities to a Sunday

As specified in
[General Norms for the Liturgical Year and the Calendar][gnlyc] 7,
the solemnities of Epiphany, Ascension and Corpus Christi
can be transferred to a Sunday.
`Temporale` by default preserves the regular dates of these
solemnities, but it has an option to enable the transfer:

```ruby
CR = CalendariumRomanum

# transfer all three to Sunday
temporale = CR::Temporale.new(2016, transfer_to_sunday: [:epiphany, :ascension, :corpus_christi])
```

Usually you don't want to work with `Temporale` alone, but with
a `Calendar`. In order to create a `Calendar` with non-default
`Temporale` settings, it is necessary to provide a `Temporale`
as third argument to the constructor.

```ruby
CR = CalendariumRomanum

year = 2000
sanctorale = CR::Data::GENERAL_ROMAN_ENGLISH.load
temporale = CR::Temporale.new(year, transfer_to_sunday: [:epiphany])

calendar = CR::Calendar.new(year, sanctorale, temporale)
```

## Custom movable feasts

Some local calendars may include proper movable feasts.
In Czech Republic this has recently been the case with the newly
introduced feast of *Christ the Priest* (celebrated on Thursday
after Pentecost). Support for this feast, celebrated in several other
dioceses and religious institutes, is included in the gem
as `Temporale` extension.

In order to build a complete Czech `Calendar` with proper sanctorale
feasts and the additional temporale feast of *Christ the Priest*,
it is necessary, apart of loading the sanctorale data,
to provide a `Temporale` instance with the extension applied:

```ruby
CR = CalendariumRomanum

year = 2016
sanctorale = CR::Data::CZECH.load
temporale =
  CR::Temporale.new(
    year,
    # the important bit: apply the Temporale extension
    extensions: [CR::Temporale::Extensions::ChristEternalPriest]
  )

calendar = CR::Calendar.new(year, sanctorale, temporale)
```

The feast of *Christ the Priest*, by it's nature, extends the cycle of
*Feasts of the Lord in the Ordinary Time* and thus clearly belongs
to the *temporale.* Even if your proper movable feast
is by it's nature a *sanctorale* feast, just having a movable
date, the only way to handle it using this gem is to write
a *temporale* extension. There is no support for movable feasts
in the `Sanctorale` class. Even the single movable sanctorale
feast of the General Roman Calendar,
the memorial of *Immaculate Heart of Mary,* is, by a little cheat,
currently implemented in the `Temporale`.

Any object defining method `each_celebration`, which yields
pairs of "date computer" and `Celebration`, can be used as
temporale extension. Unless you have a good reason to do otherwise,
a class or module defining `each_celebration` as class/module method
is a convenient choice.

```ruby
CR = CalendariumRomanum

module MyExtension
  # yields celebrations defined by the extension
  def self.each_celebration
    yield(
      :my_feast_date, # name of a method computing date of the feast
      CR::Celebration.new(
        'My Feast', # feast title
        CR::Ranks::FEAST_PROPER, # rank
        CR::Colours::WHITE # colour
      )
    )

    yield(
      # Proc can be used for date computation instead of a method
      # referenced by name
      lambda {|year| CR::Temporale::Dates.easter_sunday(year) + 9 },
      CR::Celebration.new(
        # It is possible to use a Proc as feast title if you want it
        # to be determined at runtime - e.g. because you want to
        # have the feast title translated and follow changes of `I18n.locale`
        proc { I18n.t('my_feasts.another_feast') },
        CR::Ranks::MEMORIAL_PROPER,
        CR::Colours::WHITE
      )
    )
  end

  # computes date of the feast;
  # the year passed as argument is year when the liturgical
  # year in question _begun_
  def self.my_feast_date(year)
    # the day before Christ the King
    CR::Temporale::Dates.christ_king(year) - 1
  end
end

temporale = CR::Temporale.new(2016, extensions: [MyExtension])

# the feast is there!
temporale.get(Date.new(2017, 11, 25)) # => #<CalendariumRomanum::Celebration:0x0000000246fd78 @title="My Feast", @rank=#<CalendariumRomanum::Rank:0x000000019c27e0 @priority=2.8, ... >, @colour=#<CalendariumRomanum::Colour:0x000000019c31e0 @symbol=:white>>
```
## Executable
This gem provides an executable, `calendariumrom`, which can be used for querying the sanctorale data files from command line. It currently has 5 subcommands:
 - `calendariumrom query --calendar universal-fr 2007-06-25` queries a non-default (French) calendar for any given date. `--calendar` can be omitted, the default calendar (`universal-en`) is used then. The date can be omitted as well, `calendariumrom` will query the current date, then. Please note that the date has to be in a format Ruby's `Date::parse` can understand.
 - `calendariumrom calendars` will list all available data files known to calendarium-romanum. 
 - `calendariumrom cmp FILE1 FILE2` will load 2 data files from the file system and compare them. If there are any differences in rank or colour of corresponding celebrations, it will output them. 
 - `calendariumrom errors FILE1, ...` finds errors in a data file. It tries to load it from file system, and if the parser will fail, for whatever reason, it will print out the reason. 
 - `calendariumrom help [COMMAND]` outputs a short help for all available subcommands

## How to run tests

Get the sources, install development dependencies

`bundle install`

then execute tests with

`rake spec`

See also `.travis.yml` for comprehensive tests run on the CI.

[gnlyc]: https://www.ewtn.com/library/CURIA/CDWLITYR.HTM
[i18n]: https://github.com/svenfuchs/i18n
[translations]: /tree/master/config/locales
[module-included]: http://ruby-doc.org/core-2.2.2/Module.html#method-i-included
