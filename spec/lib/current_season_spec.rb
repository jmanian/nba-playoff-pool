require "rails_helper"

describe CurrentSeason do
  shared_examples_for "presence" do |method|
    describe "::#{method}" do
      subject { described_class.public_send(method) }
      it { should be_present }
    end
  end

  %i[path params sport_year].each do |m|
    it_behaves_like "presence", m
  end

  describe "::favicon" do
    subject { described_class.favicon }

    before { expect(described_class).to receive(:sport).and_return(sport) }

    context "when the sport is nba" do
      let(:sport) { :nba }
      it { should eql "basketball.png" }
    end

    context "when the sport is mlb" do
      let(:sport) { :mlb }
      it { should eql "baseball.png" }
    end
  end
end
