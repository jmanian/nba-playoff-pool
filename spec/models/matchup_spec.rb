require 'rails_helper'

RSpec.describe Matchup, type: :model do
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

  describe '::accepting_entries' do
    subject { described_class.accepting_entries }

    let!(:future) { 2.times.map { |n| create :matchup, starts_at: 5.minutes.from_now, number: n + 1 } }

    before { 2.times.map { |n| create :matchup, starts_at: 5.minutes.ago, number: n + 3 } }

    it { is_expected.to match_array future }
  end

  describe '::started' do
    subject { described_class.started }

    let!(:past) { 2.times.map { |n| create :matchup, starts_at: 5.minutes.ago, number: n + 3 } }

    before { 2.times.map { |n| create :matchup, starts_at: 5.minutes.from_now, number: n + 1 } }

    it { is_expected.to match_array past }
  end

  describe '#favorite' do
    subject { matchup.favorite }

    context 'when in the nba' do
      let(:matchup) { create :matchup, :nba }

      it { is_expected.to eql(Team.nba(matchup.favorite_tricode)) }
    end

    context 'when in the mlb' do
      let(:matchup) { create :matchup, :mlb }

      it { is_expected.to eql(Team.mlb(matchup.favorite_tricode)) }
    end
  end

  describe '#outcome_by_index' do
    context 'with a five-game series' do
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

      context 'when 0, 0' do
        let(:wins) { [0, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 0, 1' do
        let(:wins) { [0, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 0, 2' do
        let(:wins) { [0, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 0, 3' do
        let(:wins) { [0, 3] }
        let(:expected_possibilities) { [false, false, false, false, false, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 0' do
        let(:wins) { [1, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 1' do
        let(:wins) { [1, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 2' do
        let(:wins) { [1, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 3' do
        let(:wins) { [1, 3] }
        let(:expected_possibilities) { [false, false, false, false, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 0' do
        let(:wins) { [2, 0] }
        let(:expected_possibilities) { [true, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 1' do
        let(:wins) { [2, 1] }
        let(:expected_possibilities) { [false, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 2' do
        let(:wins) { [2, 2] }
        let(:expected_possibilities) { [false, false, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 3' do
        let(:wins) { [2, 3] }
        let(:expected_possibilities) { [false, false, false, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 3, 0' do
        let(:wins) { [3, 0] }
        let(:expected_possibilities) { [true, false, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 3, 1' do
        let(:wins) { [3, 1] }
        let(:expected_possibilities) { [false, true, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 3, 2' do
        let(:wins) { [3, 2] }
        let(:expected_possibilities) { [false, false, true, false, false, false] }

        it { is_expected.to eql(results) }
      end
    end

    context 'with a seven-game series' do
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

      context 'when 0, 0' do
        let(:wins) { [0, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 0, 1' do
        let(:wins) { [0, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 0, 2' do
        let(:wins) { [0, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 0, 3' do
        let(:wins) { [0, 3] }
        let(:expected_possibilities) { [false, false, false, true, true, true, true, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 0, 4' do
        let(:wins) { [0, 4] }
        let(:expected_possibilities) { [false, false, false, false, false, false, false, true] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 0' do
        let(:wins) { [1, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 1' do
        let(:wins) { [1, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 2' do
        let(:wins) { [1, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 3' do
        let(:wins) { [1, 3] }
        let(:expected_possibilities) { [false, false, false, true, true, true, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 1, 4' do
        let(:wins) { [1, 4] }
        let(:expected_possibilities) { [false, false, false, false, false, false, true, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 0' do
        let(:wins) { [2, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 1' do
        let(:wins) { [2, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 2' do
        let(:wins) { [2, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 3' do
        let(:wins) { [2, 3] }
        let(:expected_possibilities) { [false, false, false, true, true, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 2, 4' do
        let(:wins) { [2, 4] }
        let(:expected_possibilities) { [false, false, false, false, false, true, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 3, 0' do
        let(:wins) { [3, 0] }
        let(:expected_possibilities) { [true, true, true, true, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 3, 1' do
        let(:wins) { [3, 1] }
        let(:expected_possibilities) { [false, true, true, true, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 3, 2' do
        let(:wins) { [3, 2] }
        let(:expected_possibilities) { [false, false, true, true, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 3, 3' do
        let(:wins) { [3, 3] }
        let(:expected_possibilities) { [false, false, false, true, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 3, 4' do
        let(:wins) { [3, 4] }
        let(:expected_possibilities) { [false, false, false, false, true, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 4, 0' do
        let(:wins) { [4, 0] }
        let(:expected_possibilities) { [true, false, false, false, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 4, 1' do
        let(:wins) { [4, 1] }
        let(:expected_possibilities) { [false, true, false, false, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 4, 2' do
        let(:wins) { [4, 2] }
        let(:expected_possibilities) { [false, false, true, false, false, false, false, false] }

        it { is_expected.to eql(results) }
      end

      context 'when 4, 3' do
        let(:wins) { [4, 3] }
        let(:expected_possibilities) { [false, false, false, true, false, false, false, false] }

        it { is_expected.to eql(results) }
      end
    end
  end
end
