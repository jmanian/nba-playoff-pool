require "rails_helper"

RSpec.describe Pick, type: :model do
  describe "#winner #loser" do
    subject(:winner) { pick.winner }
    subject(:loser) { pick.loser }

    context "when winner_is_favorite is true" do
      let(:pick) { create :pick, winner_is_favorite: true }
      it do
        expect(winner).to eql(pick.matchup.favorite)
        expect(loser).to eql(pick.matchup.underdog)
      end
    end

    context "when winner_is_favorite is false" do
      let(:pick) { create :pick, winner_is_favorite: false }
      it do
        expect(winner).to eql(pick.matchup.underdog)
        expect(loser).to eql(pick.matchup.favorite)
      end
    end
  end

  describe "#title" do
    subject { pick.title }
    let(:pick) { create :pick }
    it { should be_present }
  end

  describe "#code" do
    subject { pick.code }
    let(:pick) { create :pick }
    it { should be_present }
  end

  describe "#scoring_index" do
    subject { pick.scoring_index }

    context "with a seven-game series" do
      let(:matchup) { create :matchup, :seven_games }

      context "with the favorite as winner" do
        let(:pick) { create :pick, matchup: matchup, winner_is_favorite: true, num_games: num_games }

        [
          [4, 0],
          [5, 1],
          [6, 2],
          [7, 3]
        ].each do |ng, i|
          context "in #{ng} games" do
            let(:num_games) { ng }

            it { is_expected.to eql i }
          end
        end
      end

      context "with the underdog as winner" do
        let(:pick) { create :pick, matchup: matchup, winner_is_favorite: false, num_games: num_games }

        [
          [4, 7],
          [5, 6],
          [6, 5],
          [7, 4]
        ].each do |ng, i|
          context "in #{ng} games" do
            let(:num_games) { ng }

            it { is_expected.to eql i }
          end
        end
      end
    end

    context "with a five-game series" do
      let(:matchup) { create :matchup, :five_games }

      context "with the favorite as winner" do
        let(:pick) { create :pick, matchup: matchup, winner_is_favorite: true, num_games: num_games }

        [
          [3, 0],
          [4, 1],
          [5, 2]
        ].each do |ng, i|
          context "in #{ng} games" do
            let(:num_games) { ng }

            it { is_expected.to eql i }
          end
        end
      end

      context "with the underdog as winner" do
        let(:pick) { create :pick, matchup: matchup, winner_is_favorite: false, num_games: num_games }

        [
          [3, 5],
          [4, 4],
          [5, 3]
        ].each do |ng, i|
          context "in #{ng} games" do
            let(:num_games) { ng }

            it { is_expected.to eql i }
          end
        end
      end
    end
  end

  describe "points methods" do
    subject(:possible_points) { pick.possible_points }
    subject(:min_points) { pick.min_points }
    subject(:max_points) { pick.max_points }
    subject(:potential_points) { pick.potential_points }
    subject(:min_points_percentage) { pick.min_points_percentage }
    subject(:max_points_percentage) { pick.max_points_percentage }
    subject(:potential_points_percentage) { pick.potential_points_percentage }
    subject(:points_tooltip) { pick.points_tooltip }

    context "with a seven-game NBA series" do
      context "at the start of the series" do
        let(:matchup) { create :matchup, :seven_games, :nba, favorite_wins: 0, underdog_wins: 0 }

        context "with favorite in 4 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 4, winner_is_favorite: true }
          it do
            expect(possible_points).to eql([10, 6, 4, 3, 0, 0, 0, 0])
            expect(min_points).to eql(0)
            expect(max_points).to eql(10)
            expect(potential_points).to eql(10)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("Based on the results so far this pick will receive 0–10 points.")
          end
        end

        context "with favorite in 7 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 7, winner_is_favorite: true }
          it do
            expect(possible_points).to eql([3, 4, 6, 8, 4, 2, 1, 0])
            expect(min_points).to eql(0)
            expect(max_points).to eql(8)
            expect(potential_points).to eql(8)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("Based on the results so far this pick will receive 0–8 points.")
          end
        end

        context "with underdog in 7 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 7, winner_is_favorite: false }
          it do
            expect(possible_points).to eql([0, 1, 2, 4, 8, 6, 4, 3])
            expect(min_points).to eql(0)
            expect(max_points).to eql(8)
            expect(potential_points).to eql(8)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("Based on the results so far this pick will receive 0–8 points.")
          end
        end

        context "with underdog in 4 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 4, winner_is_favorite: false }
          it do
            expect(possible_points).to eql([0, 0, 0, 0, 3, 4, 6, 10])
            expect(min_points).to eql(0)
            expect(max_points).to eql(10)
            expect(potential_points).to eql(10)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("Based on the results so far this pick will receive 0–10 points.")
          end
        end
      end

      context "at 3-1" do
        let(:matchup) { create :matchup, :seven_games, :nba, favorite_wins: 3, underdog_wins: 1 }

        context "with favorite in 4 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 4, winner_is_favorite: true }
          it do
            expect(possible_points).to eql([6, 4, 3, 0])
            expect(min_points).to eql(0)
            expect(max_points).to eql(6)
            expect(potential_points).to eql(6)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("Based on the results so far this pick will receive 0–6 points.")
          end
        end

        context "with favorite in 7 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 7, winner_is_favorite: true }
          it do
            expect(possible_points).to eql([4, 6, 8, 4])
            expect(min_points).to eql(4)
            expect(max_points).to eql(8)
            expect(potential_points).to eql(4)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("Based on the results so far this pick will receive 4–8 points.")
          end
        end

        context "with underdog in 7 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 7, winner_is_favorite: false }
          it do
            expect(possible_points).to eql([1, 2, 4, 8])
            expect(min_points).to eql(1)
            expect(max_points).to eql(8)
            expect(potential_points).to eql(7)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("Based on the results so far this pick will receive 1–8 points.")
          end
        end

        context "with underdog in 4 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 4, winner_is_favorite: false }
          it do
            expect(possible_points).to eql([0, 0, 0, 3])
            expect(min_points).to eql(0)
            expect(max_points).to eql(3)
            expect(potential_points).to eql(3)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("Based on the results so far this pick will receive 0–3 points.")
          end
        end
      end

      context "at the end of the series" do
        let(:matchup) { create :matchup, :seven_games, :nba, favorite_wins: 4, underdog_wins: 3 }

        context "with favorite in 4 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 4, winner_is_favorite: true }
          it do
            expect(possible_points).to eql([3])
            expect(min_points).to eql(3)
            expect(max_points).to eql(3)
            expect(potential_points).to eql(0)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("This pick received 3 points.")
          end
        end

        context "with favorite in 7 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 7, winner_is_favorite: true }
          it do
            expect(possible_points).to eql([8])
            expect(min_points).to eql(8)
            expect(max_points).to eql(8)
            expect(potential_points).to eql(0)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("This pick received 8 points.")
          end
        end

        context "with underdog in 7 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 7, winner_is_favorite: false }
          it do
            expect(possible_points).to eql([4])
            expect(min_points).to eql(4)
            expect(max_points).to eql(4)
            expect(potential_points).to eql(0)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("This pick received 4 points.")
          end
        end

        context "with underdog in 4 games" do
          let(:pick) { create :pick, matchup: matchup, num_games: 4, winner_is_favorite: false }
          it do
            expect(possible_points).to eql([0])
            expect(min_points).to eql(0)
            expect(max_points).to eql(0)
            expect(potential_points).to eql(0)
            expect(min_points_percentage).to eql(min_points.to_f / matchup.max_possible_points)
            expect(max_points_percentage).to eql(max_points.to_f / matchup.max_possible_points)
            expect(potential_points_percentage).to eql(potential_points.to_f / matchup.max_possible_points)
            expect(points_tooltip).to eql("This pick received 0 points.")
          end
        end
      end
    end
  end
end
