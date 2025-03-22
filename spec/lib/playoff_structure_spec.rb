require "rails_helper"

describe PlayoffStructure do
  describe "::[]" do
    subject { described_class[matchup] }

    context "with an nba matchup" do
      let(:matchup) { create :matchup, :nba }
      it { should be described_class::NBA }
    end

    shared_examples_for "old mlb" do |year|
      context "with an mlb matchup for #{year}" do
        let(:matchup) { create :matchup, :mlb, year: year }
        it { should be described_class::MLB_V1 }
      end
    end

    it_behaves_like "old mlb", 2021

    shared_examples_for "new mlb" do |year|
      context "with an mlb matchup for #{year}" do
        let(:matchup) { create :matchup, :mlb, year: year }
        it { should be described_class::MLB_V2 }
      end
    end

    (2022..Date.current.year).each do |year|
      it_behaves_like "new mlb", year
    end
  end
end
