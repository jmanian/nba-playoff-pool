require "rails_helper"

RSpec.describe Pick, type: :model do
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
end
