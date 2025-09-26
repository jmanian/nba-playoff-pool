module Sync
  module Mlb
    class Client
      POSTSEASON_URL = "https://statsapi.mlb.com/api/v1/schedule/postseason/series?season=%{year}".freeze
      TEAMS_URL = "https://statsapi.mlb.com/api/v1/teams?sportId=1".freeze

      def self.fetch_postseason(year)
        new.fetch_postseason(year)
      end

      def self.fetch_teams
        new.fetch_teams
      end

      def fetch_postseason(year)
        url = POSTSEASON_URL % {year: year}
        fetch_from_url(url)
      end

      def fetch_teams
        url = TEAMS_URL
        fetch_from_url(url)
      end

      private

      def fetch_from_url(url)
        connection = Faraday.new(url: url) do |f|
          f.response :json, parser_options: {symbolize_names: true}
          f.response :raise_error
        end
        connection.get.body
      end
    end
  end
end
