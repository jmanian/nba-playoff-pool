module Sync
  module Nba
    class Matchups < MatchupBase
      def self.run(year)
        bracket = Client.fetch_bracket(year)[:bracket]
        all_series = bracket[:playoffBracketSeries]
        # The `seasonYear` in the API is the year of the season start, in the fall.
        year = bracket[:seasonYear].to_i + 1

        all_series.each do |series_data|
          sync_matchup(year, series_data)
        end
      end

      def self.sync_matchup(year, series_data)
        new(year, series_data).sync_matchup
      end

      def initialize(year, series_data)
        @year = year
        @series_data = series_data
      end

      private

      def sport
        :nba
      end

      def round
        series_data[:roundNumber].to_i
      end

      def conference
        case series_data[:seriesConference]
        when /finals/i
          "finals"
        when /east/i
          "east"
        when /west/i
          "west"
        end
      end

      def number
        case round
        when 1
          series_data[:highSeedRank].to_i
        when 2
          case series_data[:highSeedRank].to_i
          when 1, 4, 5, 8
            1
          else
            2
          end
        when 3, 4
          1
        end
      end

      def favorite_tricode
        series_data[:highSeedTricode].presence&.downcase
      end

      def underdog_tricode
        series_data[:lowSeedTricode].presence&.downcase
      end

      def favorite_wins
        series_data[:highSeedSeriesWins].to_i
      end

      def underdog_wins
        series_data[:lowSeedSeriesWins].to_i
      end

      def starts_at
        if series_data[:nextGameDateTimeUTC].present?
          Time.parse(series_data[:nextGameDateTimeUTC]) + 10.minutes
        end
      end
    end
  end
end
