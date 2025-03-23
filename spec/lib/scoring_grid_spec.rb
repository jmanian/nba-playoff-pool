require "rails_helper"

describe ScoringGrid do
  describe "::[]" do
    subject { described_class[matchup] }

    context "with an nba matchup" do
      let(:matchup) { create :matchup, :nba }
      it { should be described_class::NBA_GRID }
    end

    context "with an mlb matchup" do
      let(:matchup) { create :matchup, :mlb, year: 2022, round: round }

      context "in a 3-game round" do
        let(:round) { 1 }
        it { should be described_class::MLB_THREE_GRID }
      end

      context "in a 5-game round" do
        let(:round) { 2 }
        it { should be described_class::MLB_FIVE_GRID }
      end

      context "in a 7-game round" do
        let(:round) { 3 }
        it { should be described_class::MLB_SEVEN_GRID }
      end
    end
  end
end
