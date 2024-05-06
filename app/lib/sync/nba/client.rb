module Sync
  module Nba
    class Client
      def self.fetch_bracket(year)
        new(year).fetch_bracket
      end

      def initialize(year)
        @year = year
      end

      def fetch_bracket
        connection.get
      end

      private

      attr_reader :year

      def connection
        @connection ||= Faraday.new(url: url) do |f|
          f.response :json, content_type: content_types, parser_options: {symbolize_names: true}
          f.response :raise_error
        end
      end

      def url
        url ||= "https://cdn.nba.com/static/json/staticData/brackets/#{year - 1}/PlayoffBracket.json"
      end

      # nba.com currently sends this as text/plain rather than application/json, so we must
      # explicitly tell faraday to parse that content type as json. The regex is the default
      # value that faraday uses, so we will include that for maximum compatibility.
      def content_types
        [
          "text/plain",
          /\bjson$/
        ]
      end
    end
  end
end
