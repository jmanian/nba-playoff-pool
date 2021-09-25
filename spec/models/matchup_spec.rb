require 'rails_helper'

RSpec.describe Matchup, type: :model do
  it { is_expected.to validate_presence_of(:year) }
  it { is_expected.to validate_presence_of(:round) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:favorite_tricode) }
  it { is_expected.to validate_presence_of(:underdog_tricode) }
  it { is_expected.to validate_presence_of(:favorite_wins) }
  it { is_expected.to validate_presence_of(:underdog_wins) }
  it { is_expected.to validate_numericality_of(:year).is_equal_to(2021) }
  it { is_expected.to validate_numericality_of(:round).is_greater_than_or_equal_to(1) }

  describe '#favorite' do
    subject { matchup.favorite }

    context 'in the nba' do
      let(:matchup) { create :matchup, :nba }

      it { is_expected.to eql(Team.nba(matchup.favorite_tricode)) }
    end

    context 'in the mlb' do
      let(:matchup) { create :matchup, :mlb }

      it { is_expected.to eql(Team.mlb(matchup.favorite_tricode)) }
    end
  end
end
