require "rails_helper"

RSpec.describe Matchup, type: :model do
  it { is_expected.to validate_presence_of(:sport) }
  it { is_expected.to validate_presence_of(:year) }
  it { is_expected.to validate_presence_of(:round) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:favorite_tricode) }
  it { is_expected.to validate_presence_of(:underdog_tricode) }
  it { is_expected.to validate_presence_of(:favorite_wins) }
  it { is_expected.to validate_presence_of(:underdog_wins) }
  it { is_expected.to validate_numericality_of(:year).is_greater_than_or_equal_to(2021) }
  it { is_expected.to validate_numericality_of(:year).is_less_than_or_equal_to(Date.current.year) }
  it { is_expected.to validate_numericality_of(:round).is_greater_than_or_equal_to(1) }

  shared_examples_for "present" do |method_name|
    describe "##{method_name}" do
      subject { matchup.send(method_name) }
      let(:matchup) { create :matchup }
      it { should be_present }
    end
  end

  describe "::accepting_entries" do
    subject { described_class.accepting_entries }

    let!(:future) { (1..2).map { |n| create :matchup, starts_at: 5.minutes.from_now, number: n } }
    let!(:unknown) { (3..4).map { |n| create :matchup, starts_at: nil, number: n } }
    let!(:past) { (1..2).map { |n| create :matchup, starts_at: 5.minutes.ago, number: n, conference: :west } }

    it { is_expected.to match_array future + unknown }
  end

  describe "::started" do
    subject { described_class.started }

    let!(:future) { (1..2).map { |n| create :matchup, starts_at: 5.minutes.from_now, number: n } }
    let!(:unknown) { (3..4).map { |n| create :matchup, starts_at: nil, number: n } }
    let!(:past) { (1..2).map { |n| create :matchup, starts_at: 5.minutes.ago, number: n, conference: :west } }

    it { is_expected.to match_array past }
  end

  describe "#accepting_entries? #started?" do
    subject(:accepting_entries?) { matchup.accepting_entries? }
    subject(:started?) { matchup.started? }

    context "when starts_at is in the future" do
      let(:matchup) { create :matchup, starts_at: 1.minute.from_now }
      it do
        expect(accepting_entries?).to be true
        expect(started?).to be false
      end
    end

    context "when starts_at is unknown" do
      let(:matchup) { create :matchup, starts_at: nil }
      it do
        expect(accepting_entries?).to be true
        expect(started?).to be false
      end
    end

    context "when starts_at is in the past" do
      let(:matchup) { create :matchup, starts_at: 1.minute.ago }
      it do
        expect(accepting_entries?).to be false
        expect(started?).to be true
      end
    end
  end

  describe "#starts_at_pretty" do
    subject { matchup.starts_at_pretty }

    context "when starts_at is in the future" do
      let(:matchup) { create :matchup, starts_at: 1.minute.from_now }
      it do
        should be_present
        should_not eql "?"
      end
    end

    context "when starts_at is unknown" do
      let(:matchup) { create :matchup, starts_at: nil }
      it { should eql "?" }
    end

    context "when starts_at is in the past" do
      let(:matchup) { create :matchup, starts_at: 1.minute.ago }
      it do
        should be_present
        should_not eql "?"
      end
    end
  end

  describe "#favorite" do
    subject { matchup.favorite }

    context "when in the nba" do
      let(:matchup) { create :matchup, :nba }

      it { is_expected.to eql(Team.nba(matchup.favorite_tricode)) }
    end

    context "when in the mlb" do
      let(:matchup) { create :matchup, :mlb }

      it { is_expected.to eql(Team.mlb(matchup.favorite_tricode)) }
    end
  end

  describe "#underdog" do
    subject { matchup.underdog }

    context "when in the nba" do
      let(:matchup) { create :matchup, :nba }

      it { is_expected.to eql(Team.nba(matchup.underdog_tricode)) }
    end

    context "when in the mlb" do
      let(:matchup) { create :matchup, :mlb }

      it { is_expected.to eql(Team.mlb(matchup.underdog_tricode)) }
    end
  end

  describe "#possible_results" do
    subject { matchup.possible_results }
    context "with a seven-game series" do
      let(:matchup) { create :matchup, :seven_games }

      it do
        should eql(
          [
            ["#{matchup.favorite.name} in 4", "f-4"],
            ["#{matchup.favorite.name} in 5", "f-5"],
            ["#{matchup.favorite.name} in 6", "f-6"],
            ["#{matchup.favorite.name} in 7", "f-7"],
            ["#{matchup.underdog.name} in 7", "u-7"],
            ["#{matchup.underdog.name} in 6", "u-6"],
            ["#{matchup.underdog.name} in 5", "u-5"],
            ["#{matchup.underdog.name} in 4", "u-4"]
          ]
        )
      end
    end

    context "with a five-game series" do
      let(:matchup) { create :matchup, :five_games }

      it do
        should eql(
          [
            ["#{matchup.favorite.name} in 3", "f-3"],
            ["#{matchup.favorite.name} in 4", "f-4"],
            ["#{matchup.favorite.name} in 5", "f-5"],
            ["#{matchup.underdog.name} in 5", "u-5"],
            ["#{matchup.underdog.name} in 4", "u-4"],
            ["#{matchup.underdog.name} in 3", "u-3"]
          ]
        )
      end
    end

    context "with a three-game series" do
      let(:matchup) { create :matchup, :three_games }

      it do
        should eql(
          [
            ["#{matchup.favorite.name} in 2", "f-2"],
            ["#{matchup.favorite.name} in 3", "f-3"],
            ["#{matchup.underdog.name} in 3", "u-3"],
            ["#{matchup.underdog.name} in 2", "u-2"]
          ]
        )
      end
    end
  end

  it_behaves_like "present", "title"
  it_behaves_like "present", "favorite_name_and_wins"
  it_behaves_like "present", "underdog_name_and_wins"

  describe "#playoff_structure" do
    pending
  end

  describe "#round_structure" do
    pending
  end

  describe "#all_scores #possible_scores #max_possible_points" do
    subject(:possible_scores) { matchup.possible_scores }
    subject(:max_possible_points) { matchup.max_possible_points }

    context "for an NBA 2nd round series" do
      let(:matchup) { create :matchup, sport: :nba, round: 2, favorite_wins: favorite_wins, underdog_wins: underdog_wins }

      context "at 0-0" do
        let(:favorite_wins) { 0 }
        let(:underdog_wins) { 0 }
        it do
          expect(possible_scores).to eql(
            [
              [20, 12, 8, 6, 0, 0, 0, 0],
              [12, 16, 12, 8, 2, 0, 0, 0],
              [8, 12, 16, 12, 4, 2, 0, 0],
              [6, 8, 12, 16, 8, 4, 2, 0],
              [0, 2, 4, 8, 16, 12, 8, 6],
              [0, 0, 2, 4, 12, 16, 12, 8],
              [0, 0, 0, 2, 8, 12, 16, 12],
              [0, 0, 0, 0, 6, 8, 12, 20]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 1-0" do
        let(:favorite_wins) { 1 }
        let(:underdog_wins) { 0 }
        it do
          expect(possible_scores).to eql(
            [
              [20, 12, 8, 6, 0, 0, 0],
              [12, 16, 12, 8, 2, 0, 0],
              [8, 12, 16, 12, 4, 2, 0],
              [6, 8, 12, 16, 8, 4, 2],
              [0, 2, 4, 8, 16, 12, 8],
              [0, 0, 2, 4, 12, 16, 12],
              [0, 0, 0, 2, 8, 12, 16],
              [0, 0, 0, 0, 6, 8, 12]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 2-0" do
        let(:favorite_wins) { 2 }
        let(:underdog_wins) { 0 }
        it do
          expect(possible_scores).to eql(
            [
              [20, 12, 8, 6, 0, 0],
              [12, 16, 12, 8, 2, 0],
              [8, 12, 16, 12, 4, 2],
              [6, 8, 12, 16, 8, 4],
              [0, 2, 4, 8, 16, 12],
              [0, 0, 2, 4, 12, 16],
              [0, 0, 0, 2, 8, 12],
              [0, 0, 0, 0, 6, 8]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 3-0" do
        let(:favorite_wins) { 3 }
        let(:underdog_wins) { 0 }
        it do
          expect(possible_scores).to eql(
            [
              [20, 12, 8, 6, 0],
              [12, 16, 12, 8, 2],
              [8, 12, 16, 12, 4],
              [6, 8, 12, 16, 8],
              [0, 2, 4, 8, 16],
              [0, 0, 2, 4, 12],
              [0, 0, 0, 2, 8],
              [0, 0, 0, 0, 6]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 4-0" do
        let(:favorite_wins) { 4 }
        let(:underdog_wins) { 0 }
        it do
          expect(possible_scores).to eql(
            [
              [20],
              [12],
              [8],
              [6],
              [0],
              [0],
              [0],
              [0]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 0-1" do
        let(:favorite_wins) { 0 }
        let(:underdog_wins) { 1 }
        it do
          expect(possible_scores).to eql(
            [
              [12, 8, 6, 0, 0, 0, 0],
              [16, 12, 8, 2, 0, 0, 0],
              [12, 16, 12, 4, 2, 0, 0],
              [8, 12, 16, 8, 4, 2, 0],
              [2, 4, 8, 16, 12, 8, 6],
              [0, 2, 4, 12, 16, 12, 8],
              [0, 0, 2, 8, 12, 16, 12],
              [0, 0, 0, 6, 8, 12, 20]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 1-1" do
        let(:favorite_wins) { 1 }
        let(:underdog_wins) { 1 }
        it do
          expect(possible_scores).to eql(
            [
              [12, 8, 6, 0, 0, 0],
              [16, 12, 8, 2, 0, 0],
              [12, 16, 12, 4, 2, 0],
              [8, 12, 16, 8, 4, 2],
              [2, 4, 8, 16, 12, 8],
              [0, 2, 4, 12, 16, 12],
              [0, 0, 2, 8, 12, 16],
              [0, 0, 0, 6, 8, 12]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 2-1" do
        let(:favorite_wins) { 2 }
        let(:underdog_wins) { 1 }
        it do
          expect(possible_scores).to eql(
            [
              [12, 8, 6, 0, 0],
              [16, 12, 8, 2, 0],
              [12, 16, 12, 4, 2],
              [8, 12, 16, 8, 4],
              [2, 4, 8, 16, 12],
              [0, 2, 4, 12, 16],
              [0, 0, 2, 8, 12],
              [0, 0, 0, 6, 8]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 3-1" do
        let(:favorite_wins) { 3 }
        let(:underdog_wins) { 1 }
        it do
          expect(possible_scores).to eql(
            [
              [12, 8, 6, 0],
              [16, 12, 8, 2],
              [12, 16, 12, 4],
              [8, 12, 16, 8],
              [2, 4, 8, 16],
              [0, 2, 4, 12],
              [0, 0, 2, 8],
              [0, 0, 0, 6]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 4-1" do
        let(:favorite_wins) { 4 }
        let(:underdog_wins) { 1 }
        it do
          expect(possible_scores).to eql(
            [
              [12],
              [16],
              [12],
              [8],
              [2],
              [0],
              [0],
              [0]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 0-2" do
        let(:favorite_wins) { 0 }
        let(:underdog_wins) { 2 }
        it do
          expect(possible_scores).to eql(
            [
              [8, 6, 0, 0, 0, 0],
              [12, 8, 2, 0, 0, 0],
              [16, 12, 4, 2, 0, 0],
              [12, 16, 8, 4, 2, 0],
              [4, 8, 16, 12, 8, 6],
              [2, 4, 12, 16, 12, 8],
              [0, 2, 8, 12, 16, 12],
              [0, 0, 6, 8, 12, 20]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 1-2" do
        let(:favorite_wins) { 1 }
        let(:underdog_wins) { 2 }
        it do
          expect(possible_scores).to eql(
            [
              [8, 6, 0, 0, 0],
              [12, 8, 2, 0, 0],
              [16, 12, 4, 2, 0],
              [12, 16, 8, 4, 2],
              [4, 8, 16, 12, 8],
              [2, 4, 12, 16, 12],
              [0, 2, 8, 12, 16],
              [0, 0, 6, 8, 12]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 2-2" do
        let(:favorite_wins) { 2 }
        let(:underdog_wins) { 2 }
        it do
          expect(possible_scores).to eql(
            [
              [8, 6, 0, 0],
              [12, 8, 2, 0],
              [16, 12, 4, 2],
              [12, 16, 8, 4],
              [4, 8, 16, 12],
              [2, 4, 12, 16],
              [0, 2, 8, 12],
              [0, 0, 6, 8]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 3-2" do
        let(:favorite_wins) { 3 }
        let(:underdog_wins) { 2 }
        it do
          expect(possible_scores).to eql(
            [
              [8, 6, 0],
              [12, 8, 2],
              [16, 12, 4],
              [12, 16, 8],
              [4, 8, 16],
              [2, 4, 12],
              [0, 2, 8],
              [0, 0, 6]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 4-2" do
        let(:favorite_wins) { 4 }
        let(:underdog_wins) { 2 }
        it do
          expect(possible_scores).to eql(
            [
              [8],
              [12],
              [16],
              [12],
              [4],
              [2],
              [0],
              [0]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 0-3" do
        let(:favorite_wins) { 0 }
        let(:underdog_wins) { 3 }
        it do
          expect(possible_scores).to eql(
            [
              [6, 0, 0, 0, 0],
              [8, 2, 0, 0, 0],
              [12, 4, 2, 0, 0],
              [16, 8, 4, 2, 0],
              [8, 16, 12, 8, 6],
              [4, 12, 16, 12, 8],
              [2, 8, 12, 16, 12],
              [0, 6, 8, 12, 20]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 1-3" do
        let(:favorite_wins) { 1 }
        let(:underdog_wins) { 3 }
        it do
          expect(possible_scores).to eql(
            [
              [6, 0, 0, 0],
              [8, 2, 0, 0],
              [12, 4, 2, 0],
              [16, 8, 4, 2],
              [8, 16, 12, 8],
              [4, 12, 16, 12],
              [2, 8, 12, 16],
              [0, 6, 8, 12]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 2-3" do
        let(:favorite_wins) { 2 }
        let(:underdog_wins) { 3 }
        it do
          expect(possible_scores).to eql(
            [
              [6, 0, 0],
              [8, 2, 0],
              [12, 4, 2],
              [16, 8, 4],
              [8, 16, 12],
              [4, 12, 16],
              [2, 8, 12],
              [0, 6, 8]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 3-3" do
        let(:favorite_wins) { 3 }
        let(:underdog_wins) { 3 }
        it do
          expect(possible_scores).to eql(
            [
              [6, 0],
              [8, 2],
              [12, 4],
              [16, 8],
              [8, 16],
              [4, 12],
              [2, 8],
              [0, 6]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 4-3" do
        let(:favorite_wins) { 4 }
        let(:underdog_wins) { 3 }
        it do
          expect(possible_scores).to eql(
            [
              [6],
              [8],
              [12],
              [16],
              [8],
              [4],
              [2],
              [0]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 0-4" do
        let(:favorite_wins) { 0 }
        let(:underdog_wins) { 4 }
        it do
          expect(possible_scores).to eql(
            [
              [0],
              [0],
              [0],
              [0],
              [6],
              [8],
              [12],
              [20]
            ]
          )
          expect(max_possible_points).to eql(20)
        end
      end

      context "at 1-4" do
        let(:favorite_wins) { 1 }
        let(:underdog_wins) { 4 }
        it do
          expect(possible_scores).to eql(
            [
              [0],
              [0],
              [0],
              [2],
              [8],
              [12],
              [16],
              [12]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 2-4" do
        let(:favorite_wins) { 2 }
        let(:underdog_wins) { 4 }
        it do
          expect(possible_scores).to eql(
            [
              [0],
              [0],
              [2],
              [4],
              [12],
              [16],
              [12],
              [8]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end

      context "at 3-4" do
        let(:favorite_wins) { 3 }
        let(:underdog_wins) { 4 }
        it do
          expect(possible_scores).to eql(
            [
              [0],
              [2],
              [4],
              [8],
              [16],
              [12],
              [8],
              [6]
            ]
          )
          expect(max_possible_points).to eql(16)
        end
      end
    end
  end

  describe "#possible_remaining_results" do
    context "with a seven-game series" do
      let(:matchup) { create :matchup, :seven_games, favorite_wins: favorite_wins, underdog_wins: underdog_wins }

      context "at 0-0" do
        let(:favorite_wins) { 0 }
        let(:underdog_wins) { 0 }

        it "returns all possible results" do
          expect(matchup.possible_remaining_results).to eq([
            ["#{matchup.favorite.name} in 4", "f-4"],
            ["#{matchup.favorite.name} in 5", "f-5"],
            ["#{matchup.favorite.name} in 6", "f-6"],
            ["#{matchup.favorite.name} in 7", "f-7"],
            ["#{matchup.underdog.name} in 7", "u-7"],
            ["#{matchup.underdog.name} in 6", "u-6"],
            ["#{matchup.underdog.name} in 5", "u-5"],
            ["#{matchup.underdog.name} in 4", "u-4"]
          ])
        end
      end

      context "at 2-1" do
        let(:favorite_wins) { 2 }
        let(:underdog_wins) { 1 }

        it "returns only results still possible given the current score" do
          expect(matchup.possible_remaining_results).to eq([
            ["#{matchup.favorite.name} in 5", "f-5"],
            ["#{matchup.favorite.name} in 6", "f-6"],
            ["#{matchup.favorite.name} in 7", "f-7"],
            ["#{matchup.underdog.name} in 7", "u-7"],
            ["#{matchup.underdog.name} in 6", "u-6"]
          ])
        end
      end

      context "at 3-3" do
        let(:favorite_wins) { 3 }
        let(:underdog_wins) { 3 }

        it "returns only game 7 results" do
          expect(matchup.possible_remaining_results).to eq([
            ["#{matchup.favorite.name} in 7", "f-7"],
            ["#{matchup.underdog.name} in 7", "u-7"]
          ])
        end
      end

      context "when simulated" do
        let(:favorite_wins) { 2 }
        let(:underdog_wins) { 1 }

        it "uses original values before simulation" do
          # Simulate the matchup finishing
          matchup.favorite_wins = 4
          matchup.underdog_wins = 1

          # Should still show results based on original 2-1 score
          expect(matchup.possible_remaining_results).to eq([
            ["#{matchup.favorite.name} in 5", "f-5"],
            ["#{matchup.favorite.name} in 6", "f-6"],
            ["#{matchup.favorite.name} in 7", "f-7"],
            ["#{matchup.underdog.name} in 7", "u-7"],
            ["#{matchup.underdog.name} in 6", "u-6"]
          ])
        end
      end
    end
  end

  describe "#outcome_by_index" do
    context "with a five-game series" do
      subject { (0..5).map { |i| matchup.outcome_by_index(i) } }

      let(:matchup) { create :matchup, :five_games, favorite_wins: wins.first, underdog_wins: wins.last }
      let(:expected_team_and_games) do
        [
          [matchup.favorite, 3],
          [matchup.favorite, 4],
          [matchup.favorite, 5],
          [matchup.underdog, 5],
          [matchup.underdog, 4],
          [matchup.underdog, 3]
        ]
      end
      let(:results) { expected_team_and_games.zip(expected_possibilities).map(&:flatten) }

      context "when 0, 0" do
        let(:wins) { [0, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context "when 0, 1" do
        let(:wins) { [0, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context "when 0, 2" do
        let(:wins) { [0, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context "when 0, 3" do
        let(:wins) { [0, 3] }
        let(:expected_possibilities) { [false, false, false, false, false, true] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 0" do
        let(:wins) { [1, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 1" do
        let(:wins) { [1, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 2" do
        let(:wins) { [1, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 3" do
        let(:wins) { [1, 3] }
        let(:expected_possibilities) { [false, false, false, false, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 0" do
        let(:wins) { [2, 0] }
        let(:expected_possibilities) { [true, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 1" do
        let(:wins) { [2, 1] }
        let(:expected_possibilities) { [false, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 2" do
        let(:wins) { [2, 2] }
        let(:expected_possibilities) { [false, false, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 3" do
        let(:wins) { [2, 3] }
        let(:expected_possibilities) { [false, false, false, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 3, 0" do
        let(:wins) { [3, 0] }
        let(:expected_possibilities) { [true, false, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 3, 1" do
        let(:wins) { [3, 1] }
        let(:expected_possibilities) { [false, true, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 3, 2" do
        let(:wins) { [3, 2] }
        let(:expected_possibilities) { [false, false, true, false, false, false] }

        it { is_expected.to eql(results) }
      end
    end

    context "with a seven-game series" do
      subject { (0..7).map { |i| matchup.outcome_by_index(i) } }

      let(:matchup) { create :matchup, :seven_games, favorite_wins: wins.first, underdog_wins: wins.last }
      let(:expected_team_and_games) do
        [
          [matchup.favorite, 4],
          [matchup.favorite, 5],
          [matchup.favorite, 6],
          [matchup.favorite, 7],
          [matchup.underdog, 7],
          [matchup.underdog, 6],
          [matchup.underdog, 5],
          [matchup.underdog, 4]
        ]
      end
      let(:results) { expected_team_and_games.zip(expected_possibilities).map(&:flatten) }

      context "when 0, 0" do
        let(:wins) { [0, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context "when 0, 1" do
        let(:wins) { [0, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context "when 0, 2" do
        let(:wins) { [0, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context "when 0, 3" do
        let(:wins) { [0, 3] }
        let(:expected_possibilities) { [false, false, false, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context "when 0, 4" do
        let(:wins) { [0, 4] }
        let(:expected_possibilities) { [false, false, false, false, false, false, false, true] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 0" do
        let(:wins) { [1, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 1" do
        let(:wins) { [1, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 2" do
        let(:wins) { [1, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 3" do
        let(:wins) { [1, 3] }
        let(:expected_possibilities) { [false, false, false, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 1, 4" do
        let(:wins) { [1, 4] }
        let(:expected_possibilities) { [false, false, false, false, false, false, true, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 0" do
        let(:wins) { [2, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 1" do
        let(:wins) { [2, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 2" do
        let(:wins) { [2, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 3" do
        let(:wins) { [2, 3] }
        let(:expected_possibilities) { [false, false, false, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 2, 4" do
        let(:wins) { [2, 4] }
        let(:expected_possibilities) { [false, false, false, false, false, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 3, 0" do
        let(:wins) { [3, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 3, 1" do
        let(:wins) { [3, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 3, 2" do
        let(:wins) { [3, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 3, 3" do
        let(:wins) { [3, 3] }
        let(:expected_possibilities) { [false, false, false, true, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 3, 4" do
        let(:wins) { [3, 4] }
        let(:expected_possibilities) { [false, false, false, false, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 4, 0" do
        let(:wins) { [4, 0] }
        let(:expected_possibilities) { [true, false, false, false, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 4, 1" do
        let(:wins) { [4, 1] }
        let(:expected_possibilities) { [false, true, false, false, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 4, 2" do
        let(:wins) { [4, 2] }
        let(:expected_possibilities) { [false, false, true, false, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context "when 4, 3" do
        let(:wins) { [4, 3] }
        let(:expected_possibilities) { [false, false, false, true, false, false, false, false] }

        it { is_expected.to eql(results) }
      end
    end
  end
end
