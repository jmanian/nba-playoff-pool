require "rails_helper"

describe UserScores::Total do
  let(:total_scores) { described_class.build(picks) }
  let(:users) { create_list :user, 15 }

  let!(:matchups) do
    [
      *(1..4).map { |n| create :matchup, :started, :nba, round: 1, number: n, favorite_wins: n, underdog_wins: 1 },
      *(1..2).map { |n| create :matchup, :started, :nba, round: 2, number: n, favorite_wins: n, underdog_wins: 2 }
    ]
  end

  let!(:picks) do
    users.product(matchups).map do |user, matchup|
      create :pick, user: user, matchup: matchup
    end
  end

  describe "#build" do
    it "returns the total scores for the users" do
      expect(total_scores.map(&:user)).to match_array(users)
    end
  end

  describe "#score_summary" do
    let(:total_score) { total_scores.first }

    context "when the min and max totals are the same" do
      before do
        allow(total_score).to receive(:min_total).and_return(total_score.max_total)
      end

      it "returns the max total" do
        expect(total_score.score_summary).to eq(total_score.max_total.to_s)
      end
    end

    context "when the min and max totals are different" do
      before do
        allow(total_score).to receive(:min_total).and_return(total_score.max_total - 1)
      end

      it "returns the min and max totals" do
        expect(total_score.score_summary).to eq("#{total_score.min_total}–#{total_score.max_total}")
      end
    end
  end
end
