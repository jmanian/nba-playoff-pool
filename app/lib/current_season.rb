module CurrentSeason
  SPORT = :mlb
  YEAR = 2021

  PATH = "/#{SPORT}/#{YEAR}".freeze
  PARAMS = {sport: SPORT, year: YEAR}.freeze
  SPORT_YEAR = [SPORT, YEAR].freeze

  class << self
    def path
      PATH
    end

    def params
      PARAMS
    end

    def sport_year
      SPORT_YEAR
    end
  end
end
