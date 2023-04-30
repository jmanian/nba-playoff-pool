module CurrentSeason
  SPORT = :nba
  YEAR = 2023

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

    def favicon
      case sport
      when :nba
        "basketball.png"
      when :mlb
        "baseball.png"
      end
    end
  end
end
