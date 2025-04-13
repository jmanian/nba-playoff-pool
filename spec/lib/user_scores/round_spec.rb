require "rails_helper"

describe UserScores::Round do
  let(:round_scores) { described_class.build(picks) }
  let(:users) { create_list :user, 15 }

  let!(:matchups) do
    (1..4).map { |n| create :matchup, :nba, number: n, favorite_wins: n, underdog_wins: 1 }
  end

  let!(:picks) do
    users.product(matchups).map do |user, matchup|
      create :pick, user: user, matchup: matchup
    end
  end

  describe "#pick_for_matchup" do
    it "gets the user's pick for the matchup" do
      round_scores.product(matchups).each do |round_score, matchup|
        pick = round_score.pick_for_matchup(matchup.id)
        expect(pick.user).to eql(round_score.user)
        expect(pick.matchup).to eql(matchup)
      end
    end
  end

  describe "points methods" do

    context "when the round is not finished" do
      it "gets the various points for the user's round" do
        round_scores.each do |round_score|
          expect(round_score.min_total).to eql(round_score.picks.sum(&:min_points))
          expect(round_score.potential_total).to eql(round_score.picks.sum(&:potential_points))
          expect(round_score.max_total).to eql(round_score.picks.sum(&:max_points))
          expect(round_score.totals).to eql([round_score.min_total, round_score.potential_total, round_score.max_total])
          expect(round_score.min_total_percentage).to eql(round_score.min_total.to_f / round_score.max_possible_round_total)
          expect(round_score.potential_total_percentage).to eql(round_score.potential_total.to_f / round_score.max_possible_round_total)
          expect(round_score.points_tooltip).to eq("Based on the results so far these picks will receive #{round_score.min_total}–#{round_score.max_total} #{"point".pluralize(round_score.max_total)}.")
        end
      end
    end

    context "when the round is finished" do
      let!(:matchups) do
        (1..4).map { |n| create :matchup, :nba, number: n, favorite_wins: 4, underdog_wins: [n, 3].min }
      end
      it "gets the various points for the user's round" do
        round_scores.each do |round_score|
          expect(round_score.min_total).to eql(round_score.picks.sum(&:min_points))
          expect(round_score.potential_total).to eql(round_score.picks.sum(&:potential_points))
          expect(round_score.max_total).to eql(round_score.picks.sum(&:max_points))
          expect(round_score.totals).to eql([round_score.min_total, round_score.potential_total, round_score.max_total])
          expect(round_score.min_total_percentage).to eql(round_score.min_total.to_f / round_score.max_possible_round_total)
          expect(round_score.potential_total_percentage).to eql(round_score.potential_total.to_f / round_score.max_possible_round_total)
          expect(round_score.points_tooltip).to eq("These picks received #{round_score.min_total} #{"point".pluralize(round_score.min_total)}.")
        end
      end
    end
  end



end
