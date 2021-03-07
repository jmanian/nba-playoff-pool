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
  it { is_expected.to validate_numericality_of(:round).is_greater_than_or_equal_to(1).is_less_than_or_equal_to(4) }

  describe '#favorite' do
    subject { matchup.favorite }

    let(:matchup) { create :matchup }

    it { is_expected.to eql(Team[matchup.favorite_tricode]) }
  end
end
