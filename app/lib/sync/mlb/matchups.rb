module Sync
  module Mlb
    class Matchups < MatchupBase
      def self.run(year)
        team_data = Client.fetch_teams[:teams]
        team_ids_to_abbreviations = team_data.to_h { |t| [t[:id], t[:abbreviation].downcase] }

        all_series = Client.fetch_postseason(year)
        all_series[:series].each do |series_data|
          sync_matchup(year, series_data, team_ids_to_abbreviations)
        end
      end

      def self.sync_matchup(year, series_data, team_ids_to_abbreviations)
        new(year, series_data, team_ids_to_abbreviations).sync_matchup
      end

      def initialize(year, series_data, team_ids_to_abbreviations)
        @year = year
        @series_data = series_data
        @team_ids_to_abbreviations = team_ids_to_abbreviations
      end

      attr_reader :team_ids_to_abbreviations

      def sport
        :mlb
      end

      def round
        case series_data[:series][:gameType]
        when "F"
          1
        when "D"
          2
        when "L"
          3
        when "W"
          4
        end
      end

      def conference
        return "ws" if series_data[:series][:gameType] == "W"

        case series_data[:games].first[:description]
        when /AL/
          "al"
        when /NL/
          "nl"
        end
      end

      def number
        # the id looks like F_2 or W_1, etc.
        raw_number = series_data[:series][:id].split("_").last.to_i

        # Series are numered consecutively within the round, starting at 1, and the AL
        # series come first.
        if conference == "nl"
          raw_number - PlayoffStructure::MLB_V2[round - 1][:matchups_per_conference]
        else
          raw_number
        end
      end

      def favorite_team_id
        series_data[:games].first[:teams][:home][:team][:id]
      end

      def favorite_tricode
        translate_team_abbreviation(team_ids_to_abbreviations[favorite_team_id])
      end

      def underdog_team_id
        series_data[:games].first[:teams][:away][:team][:id]
      end

      def underdog_tricode
        translate_team_abbreviation(team_ids_to_abbreviations[underdog_team_id])
      end

      def favorite_wins
        series_data[:games].last[:teams].values.find { |t| t[:team][:id] == favorite_team_id }[:leagueRecord][:wins]
      end

      def underdog_wins
        series_data[:games].last[:teams].values.find { |t| t[:team][:id] == underdog_team_id }[:leagueRecord][:wins]
      end

      # Translate API team abbreviations that differ from Team::MLB_TEAMS
      def translate_team_abbreviation(abbreviation)
        case abbreviation
        when "ath"
          "oak"
        when "az"
          "ari"
        else
          abbreviation
        end
      end

      def starts_at
        if series_data[:games].first[:gameDate].present?
          Time.parse(series_data[:games].first[:gameDate])
        end
      end
    end
  end
end
