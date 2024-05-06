module Sync
  module Nba
    class Matchups
      def self.run(year)
        bracket = Client.fetch_bracket(year)[:bracket]
        all_series = bracket[:playoffBracketSeries]
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

      def sync_matchup
        if series_started?
          sync_wins
        elsif teams_known?
          create_matchup
        end
      end

      private

      attr_reader :year, :series_data

      def sync_wins
        find_existing_matchup&.update!(favorite_wins: favorite_wins, underdog_wins: underdog_wins)
      end

      def create_matchup
        return if find_existing_matchup

        Matchup.create!(
          sport: :nba,
          year: year,
          round: round,
          conference: conference,
          number: number,
          favorite_tricode: favorite_tricode,
          underdog_tricode: underdog_tricode,
          favorite_wins: favorite_wins,
          underdog_wins: underdog_wins,
          starts_at: starts_at
        )
      end

      def find_existing_matchup
        matchup_base = Matchup.where(sport: :nba, year: year, round: round, conference: conference)

        matchup_base.find_by(favorite_tricode: favorite_tricode, underdog_tricode: underdog_tricode) ||
        matchup_base.find_by(favorite_tricode: underdog_tricode, underdog_tricode: favorite_tricode)
      end

      def series_started?
        favorite_wins > 0 || underdog_wins > 0
      end

      def teams_known?
        favorite_tricode && underdog_tricode
      end

      def round
        series_data[:roundNumber].to_i
      end

      def conference
        series_data[:seriesConference].downcase
      end

      def number
        case round
        when 1
          series_data[:highSeedRank]
        when 2
          case series_data[:highSeedRank]
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
        series_data[:highSeedTricode]&.downcase
      end

      def underdog_tricode
        series_data[:lowSeedTricode]&.downcase
      end

      def favorite_wins
        series_data[:highSeedSeriesWins].to_i
      end

      def underdog_wins
        series_data[:lowSeedSeriesWins].to_i
      end

      def starts_at
        Time.parse(series_data[:nextGameDateTimeUTC]) + 10.minutes
      end
    end
  end
end
