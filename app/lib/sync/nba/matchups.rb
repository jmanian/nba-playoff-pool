module Sync
  module Nba
    class Matchups
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
        matchup = find_existing_matchup

        if matchup
          matchup.favorite_wins = favorite_wins
          matchup.underdog_wins = underdog_wins
          if matchup.has_changes_to_save?
            matchup.save!
            Rails.logger.info("Matchup updated: #{matchup.saved_changes.except(:updated_at).to_json}")
          end
        end
      end

      def create_matchup
        return if find_existing_matchup || find_existing_reversed_matchup

        matchup = Matchup.create!(
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

        Rails.logger.info("Matchup created: #{matchup.attributes.except("created_at", "updated_at").to_json}")
      end

      def find_existing_matchup
        matchup_base.find_by(favorite_tricode: favorite_tricode, underdog_tricode: underdog_tricode)
      end

      # Just to be extra careful, this looks for a matchup where the teams are reversed.
      def find_existing_reversed_matchup
        matchup_base.find_by(favorite_tricode: underdog_tricode, underdog_tricode: favorite_tricode)
      end

      def matchup_base
        Matchup.where(sport: :nba, year: year, round: round, conference: conference)
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
