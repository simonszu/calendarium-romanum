module CalendariumRomanum
  class Temporale
    # dates of movable feasts
    module Dates
      def self.first_advent_sunday(year)
        return sunday_before(nativity(year)) - 3 * Temporale::WEEK
      end

      def self.nativity(year)
        return Date.new(year, 12, 25)
      end

      def self.holy_family(year)
        xmas = nativity(year)
        if xmas.sunday?
          return Date.new(year, 12, 30)
        else
          sunday_after(xmas)
        end
      end

      def self.mother_of_god(year)
        octave_of(nativity(year))
      end

      def self.epiphany(year)
        return Date.new(year+1, 1, 6)
      end

      def self.baptism_of_lord(year)
        return sunday_after epiphany(year)
      end

      def self.ash_wednesday(year)
        return easter_sunday(year) - (6 * Temporale::WEEK + 4)
      end

      def self.easter_sunday(year)
        year += 1

        # algorithm below taken from the 'easter' gem:
        # https://github.com/jrobertson/easter

        golden_number = (year % 19) + 1
        if year <= 1752 then
          # Julian calendar
          dominical_number = (year + (year / 4) + 5) % 7
          paschal_full_moon = (3 - (11 * golden_number) - 7) % 30
        else
          # Gregorian calendar
          dominical_number = (year + (year / 4) - (year / 100) + (year / 400)) % 7
          solar_correction = (year - 1600) / 100 - (year - 1600) / 400
          lunar_correction = (((year - 1400) / 100) * 8) / 25
          paschal_full_moon = (3 - 11 * golden_number + solar_correction - lunar_correction) % 30
        end
        dominical_number += 7 until dominical_number > 0
        paschal_full_moon += 30 until paschal_full_moon > 0
        paschal_full_moon -= 1 if paschal_full_moon == 29 or (paschal_full_moon == 28 and golden_number > 11)
        difference = (4 - paschal_full_moon - dominical_number) % 7
        difference += 7 if difference < 0
        day_easter = paschal_full_moon + difference + 1
        if day_easter < 11 then
          # Easter occurs in March.
          return Date.new(y=year, m=3, d=day_easter + 21)
        else
          # Easter occurs in April.
          return Date.new(y=year, m=4, d=day_easter - 10)
        end
      end

      def self.palm_sunday(year)
        return easter_sunday(year) - 7
      end

      def self.good_friday(year)
        return easter_sunday(year) - 2
      end

      def self.holy_saturday(year)
        return easter_sunday(year) - 1
      end

      def self.ascension(year)
        return pentecost(year) - 10
      end

      def self.pentecost(year)
        return easter_sunday(year) + 7 * Temporale::WEEK
      end

      def self.holy_trinity(year)
        sunday_after(pentecost(year))
      end

      def self.body_blood(year)
        thursday_after(holy_trinity(year))
      end

      def self.sacred_heart(year)
        friday_after(sunday_after(body_blood(year)))
      end

      def self.immaculate_heart(year)
        pentecost(year) + 20
      end

      def self.christ_king(year)
        sunday_before(first_advent_sunday(year + 1))
      end

      # utility methods

      def self.weekday_before(weekday, date)
        if date.wday == weekday then
          return date - Temporale::WEEK
        elsif weekday < date.wday
          return date - (date.wday - weekday)
        else
          return date - (date.wday + Temporale::WEEK - weekday)
        end
      end

      def self.weekday_after(weekday, date)
        if date.wday == weekday then
          return date + Temporale::WEEK
        elsif weekday > date.wday
          return date + (weekday - date.wday)
        else
          return date + (Temporale::WEEK - date.wday + weekday)
        end
      end

      def self.octave_of(date)
        date + Temporale::WEEK
      end

      class << self
        WEEKDAYS = %w{sunday monday tuesday wednesday thursday friday saturday}
        WEEKDAYS.each_with_index do |weekday, weekday_i|
          define_method "#{weekday}_before" do |date|
            send('weekday_before', weekday_i, date)
          end

          define_method "#{weekday}_after" do |date|
            send('weekday_after', weekday_i, date)
          end
        end
      end
    end
  end
end