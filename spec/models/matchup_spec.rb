require 'rails_helper'

RSpec.describe Matchup, type: :model do
  describe '#favorite' do
    subject { matchup.favorite }

    let(:matchup) { create :matchup }

    it { is_expected.to eql(Team[matchup.favorite_tricode]) }
  end
end
