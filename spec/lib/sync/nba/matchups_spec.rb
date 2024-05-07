require "rails_helper"

RSpec.describe Sync::Nba::Matchups do
  describe "#sync_matchup" do
    subject { instance.sync_matchup }
    let(:instance) { described_class.new(year, series_data) }

    let(:year) { 2024 }
    let(:series_data) do
      {
        roundNumber: round_number,
        seriesConference: series_conference,
        highSeedRank: favorite_seed,
        highSeedTricode: favorite_tricode.to_s.upcase,
        lowSeedTricode: underdog_tricode.to_s.upcase,
        highSeedSeriesWins: favorite_wins,
        lowSeedSeriesWins: underdog_wins,
        nextGameDateTimeUTC: next_game_at_pretty
      }
    end

    let(:next_game_at_pretty) { next_game_at&.strftime("%FT%TZ") }
    let(:next_game_at) { 1.day.from_now.beginning_of_hour }

    let(:expected_attributes) do
      {
        sport: "nba",
        year: year,
        round: round_number,
        conference: conference,
        number: number,
        favorite_tricode: favorite_tricode,
        underdog_tricode: underdog_tricode,
        favorite_wins: favorite_wins,
        underdog_wins: underdog_wins,
        starts_at: starts_at
      }
    end

    shared_examples_for "syncing" do
      context "when the series hasn't started yet" do
        let(:favorite_wins) { 0 }
        let(:underdog_wins) { 0 }
        let(:starts_at) { next_game_at + 10.minutes if next_game_at }

        context "when there's no existing matchup" do

          shared_examples_for "creates matchup" do
            it "creates a matchup" do
              subject
              expect(Matchup.count).to eql(2)
              matchup = Matchup.last

              expect(matchup).to have_attributes(expected_attributes)
            end
          end

          context "when the first game is unknown" do
            let(:next_game_at) { nil }
            it_behaves_like "creates matchup"
          end

          context "when the first game is known" do
            it_behaves_like "creates matchup"
          end
        end

        context "when there's an existing matchup" do
          let!(:matchup) do
            create :matchup, year: year, round: round_number, conference: conference, number: number,
              favorite_tricode: favorite_tricode, underdog_tricode: underdog_tricode,
              favorite_wins: favorite_wins, underdog_wins: underdog_wins, starts_at: initial_starts_at
          end

          context "when there's starts_at and no next_game_at" do
            let(:initial_starts_at) { nil }
            let(:next_game_at) { nil }

            it "does nothing" do
              expect(Matchup.count).to eql(2)
              subject
              expect(Matchup.count).to eql(2)
              expect(matchup.reload).to have_attributes(expected_attributes)
              expect(matchup.starts_at).to be_nil
            end
          end

          context "when there's no initial starts_at and there is a next game" do
            let(:initial_starts_at) { nil }
            let(:next_game_at) { 1.day.from_now.beginning_of_hour }
            it "updates starts_at" do
              expect(Matchup.count).to eql(2)
              subject
              expect(Matchup.count).to eql(2)
              expect(matchup.reload).to have_attributes(expected_attributes)
              expect(matchup.starts_at).to be_present
            end
          end

          context "when there's an initial starts_at and the next game is different" do
            let(:initial_starts_at) { 1.day.from_now.beginning_of_hour }
            let(:next_game_at) { 2.days.from_now.beginning_of_hour }
            let(:starts_at) { initial_starts_at }
            it "does not update starts_at" do
              expect(Matchup.count).to eql(2)
              subject
              expect(Matchup.count).to eql(2)
              expect(matchup.reload).to have_attributes(expected_attributes)
              expect(matchup.starts_at).to be_present
            end
          end
        end
      end

      context "when the series has started" do
        let(:favorite_wins) { 1 }
        let(:underdog_wins) { 1 }

        context "when the matchup isn't found" do
          it "does nothing" do
            expect(Matchup.count).to eql(1)
            subject
            expect(Matchup.count).to eql(1)
          end
        end

        context "when the matchup is found" do
          let!(:matchup) do
            create :matchup, year: year, round: round_number, conference: conference, number: number,
              favorite_tricode: favorite_tricode, underdog_tricode: underdog_tricode,
              favorite_wins: 0, underdog_wins: 0, starts_at: starts_at
          end
          let(:starts_at) { next_game_at - 1.hour }

          it "updates the wins and not starts_at" do
            expect(Matchup.count).to eql(2)
            subject
            expect(Matchup.count).to eql(2)
            expect(matchup.reload).to have_attributes(expected_attributes)
          end
        end
      end
    end

    context "when it's the east first round" do
      let(:round_number) { 1 }
      let(:series_conference) { "East" }
      let(:conference) { "east" }
      let(:favorite_seed) { 3 }
      let(:number) { favorite_seed }
      let(:favorite_tricode) { "nyk" }
      let(:underdog_tricode) { "bos" }
      let!(:other_matchup) { create :matchup, year: year, round: 1, conference: "east", number: 2, favorite_tricode: "atl", underdog_tricode: "phi"}

      it_behaves_like "syncing"
    end

    context "when it's the west second round" do
      let(:round_number) { 2 }
      let(:series_conference) { "West" }
      let(:conference) { "west" }
      let(:favorite_seed) { 3 }
      let(:number) { 2 }
      let(:favorite_tricode) { "gsw" }
      let(:underdog_tricode) { "lal" }
      let!(:other_matchup) { create :matchup, year: year, round: 2, conference: "west", number: 1, favorite_tricode: "lac", underdog_tricode: "dal"}

      it_behaves_like "syncing"
    end

    context "when it's the east third round" do
      let(:round_number) { 3 }
      let(:series_conference) { "East" }
      let(:conference) { "east" }
      let(:favorite_seed) { 8 }
      let(:number) { 1 }
      let(:favorite_tricode) { "nyk" }
      let(:underdog_tricode) { "bos" }
      let!(:other_matchup) { create :matchup, year: year, round: 3, conference: "west", number: 1, favorite_tricode: "lac", underdog_tricode: "dal"}

      it_behaves_like "syncing"
    end

    context "when it's the finals" do
      let(:round_number) { 4 }
      let(:series_conference) { "NBA Finals" }
      let(:conference) { "finals" }
      let(:favorite_seed) { 8 }
      let(:number) { 1 }
      let(:favorite_tricode) { "nyk" }
      let(:underdog_tricode) { "gsw" }
      let!(:other_matchup) { create :matchup, year: year, round: 3, conference: "west", number: 1, favorite_tricode: "lac", underdog_tricode: "dal"}

      it_behaves_like "syncing"
    end
  end
end
