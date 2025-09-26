require "rails_helper"

RSpec.describe Sync::Mlb::Client do
  describe "::fetch_postseason", :vcr do
    subject { described_class.fetch_postseason(year) }

    context "for the 2024 playoffs" do
      let(:year) { 2024 }

      it "returns the JSON from the 2024 postseason series endpoint" do
        expect(subject[:series]).to be_an(Array)
        expect(subject[:series]).not_to be_empty

        random_series = subject[:series].sample
        random_game = random_series[:games].sample
        expect(random_game[:season]).to eq(year.to_s)
      end
    end

    context "for the 2023 playoffs" do
      let(:year) { 2023 }

      it "returns the JSON from the 2023 postseason series endpoint" do
        expect(subject[:series]).to be_an(Array)
        expect(subject[:series]).not_to be_empty

        random_series = subject[:series].sample
        random_game = random_series[:games].sample
        expect(random_game[:season]).to eq(year.to_s)
      end
    end
  end

  describe "::fetch_teams", :vcr do
    subject { described_class.fetch_teams }

    it "returns the JSON from the teams endpoint" do
      should include(:teams)
      expect(subject[:teams]).to be_an(Array)
      expect(subject[:teams]).not_to be_empty
    end
  end
end
