require "rails_helper"

RSpec.describe Sync::Mlb::Matchups do
  describe "::run" do
    subject { described_class.run(year) }

    let(:year) { rand(2020..2025) }
    let(:teams_data) do
      {
        teams: teams
      }
    end
    let(:teams) do
      [
        {
          id: 1,
          abbreviation: "LAD"
        },
        {
          id: 2,
          abbreviation: "NYY"
        }
      ]
    end
    let(:postseason_data) do
      {
        series: series
      }
    end
    let(:series) do
      [
        {
          data: 1
        },
        {
          data: 2
        }
      ]
    end
    let(:team_ids_to_abbreviations) do
      {
        1 => "lad",
        2 => "nyy"
      }
    end

    it "syncs all the matchups from the fetched postseason data" do
      expect(Sync::Mlb::Client).to receive(:fetch_teams).and_return(teams_data)
      expect(Sync::Mlb::Client).to receive(:fetch_postseason).with(year).and_return(postseason_data)
      series.each do |s|
        expect(described_class).to receive(:sync_matchup).with(year, s, team_ids_to_abbreviations)
      end

      subject
    end
  end

  describe "::sync_matchup" do
    subject { described_class.sync_matchup(year, series_data, team_ids_to_abbreviations) }

    let(:year) { rand(2020..2025) }
    let(:series_data) { {data: SecureRandom.hex} }
    let(:team_ids_to_abbreviations) { {1 => "lad", 2 => "nyy"} }

    it "syncs with an instance" do
      expect_any_instance_of(described_class).to receive(:sync_matchup) do |instance|
        expect(instance.instance_variable_get(:@year)).to eql(year)
        expect(instance.instance_variable_get(:@series_data)).to eql(series_data)
        expect(instance.instance_variable_get(:@team_ids_to_abbreviations)).to eql(team_ids_to_abbreviations)
      end
      subject
    end
  end
end
