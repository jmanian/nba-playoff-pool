module CurrentSeason
  SPORT = :nba
  YEAR = 2025

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
