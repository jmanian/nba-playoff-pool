require 'rails_helper'

RSpec.describe Matchup, type: :model do
  describe '#favorite' do
    let(:matchup) { create :matchup }
    subject { matchup.favorite }
    it { should eql(Team[matchup.favorite_tricode]) }
  end
end
