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
end
