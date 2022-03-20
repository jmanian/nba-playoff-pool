module CurrentSeason
  SPORT = :mlb
  YEAR = 2021

  PATH = "/#{SPORT}/#{YEAR}".freeze
  PARAMS = {sport: SPORT, year: YEAR}.freeze
  SPORT_YEAR = [SPORT, YEAR].freeze

  class << self
    def sport
      SPORT
    end

    def year
      YEAR
    end

    def path
      @path ||= "/#{sport}/#{year}".freeze
    end

    def params
      @params ||= {sport: sport, year: year}.freeze
    end

    def sport_year
      @sport_year ||= [sport, year].freeze
    end
  end
end
