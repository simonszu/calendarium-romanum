module CalendariumRomanum
  class Temporale
    # builds temporale Celebrations
    class CelebrationFactory
      class << self
        def first_advent_sunday
          Celebration.new(
            I18n.t("temporale.advent.sunday", week: Ordinalizer.ordinal(1)),
            Ranks::PRIMARY,
            Colours::VIOLET
          )
        end

        private

        def celebration(symbol, rank, colour=Colours::WHITE)
          define_singleton_method(symbol) do
            Celebration.new(
              proc { I18n.t("temporale.solemnity.#{symbol}") },
              rank,
              colour,
              symbol
            )
          end
        end
      end

      # define factory methods
      celebration(:nativity, Ranks::PRIMARY)
      celebration(:holy_family, Ranks::FEAST_LORD_GENERAL)
      celebration(:mother_of_god, Ranks::SOLEMNITY_GENERAL)
      celebration(:epiphany, Ranks::PRIMARY)
      celebration(:baptism_of_lord, Ranks::FEAST_LORD_GENERAL)
      celebration(:ash_wednesday, Ranks::PRIMARY, Colours::VIOLET)
      celebration(:good_friday, Ranks::TRIDUUM, Colours::RED)
      celebration(:holy_saturday, Ranks::TRIDUUM, Colours::VIOLET)
      celebration(:palm_sunday, Ranks::PRIMARY, Colours::RED)
      celebration(:easter_sunday, Ranks::TRIDUUM)
      celebration(:ascension, Ranks::PRIMARY)
      celebration(:pentecost, Ranks::PRIMARY, Colours::RED)
      celebration(:holy_trinity, Ranks::SOLEMNITY_GENERAL)
      celebration(:corpus_christi, Ranks::SOLEMNITY_GENERAL)
      celebration(:sacred_heart, Ranks::SOLEMNITY_GENERAL)
      celebration(:christ_king, Ranks::SOLEMNITY_GENERAL)
      celebration(:immaculate_heart, Ranks::MEMORIAL_GENERAL)
    end
  end
end
