require "rails_helper"

describe Team do
  describe "#full_name" do
    subject { team.full_name }
    let(:team) { described_class::NBA_TEAMS.values.sample }
    it { should be_present }
  end

  describe "::NBA_TEAMS" do
    subject { described_class::NBA_TEAMS }

    it { expect(subject.values).to all be_a described_class }
    it { expect(subject.length).to eql(30) }
  end

  describe "::MLB_TEAMS" do
    subject { described_class::MLB_TEAMS }

    it { expect(subject.values).to all be_a described_class }
    it { expect(subject.length).to eql(30) }
  end

  describe "::nba_tricodes" do
    subject { described_class.nba_tricodes }

    it { should all be_a String }
    it { expect(subject.length).to eql(30) }
  end

  describe "::mlb_tricodes" do
    subject { described_class.mlb_tricodes }

    it { should all be_a String }
    it { expect(subject.length).to eql(30) }
  end

  describe "::tricodes_for_enum" do
    subject { described_class.tricodes_for_enum }

    it { expect(subject.keys).to match_array(described_class.nba_tricodes | described_class.mlb_tricodes) }
    it do
      subject.each do |key, val|
        expect(key).to eql(val)
      end
    end
  end

  describe "::nba" do
    subject { described_class.nba(tricode) }

    shared_examples_for "nba team" do |tc|
      context "with #{tc}" do
        let(:tricode) { tc }
        it "returns the right team" do
          expect(subject.tricode).to eql tricode.to_sym
        end
      end
    end

    described_class.nba_tricodes.each do |tc|
      it_behaves_like "nba team", tc
    end
  end

  describe "::mlb" do
    subject { described_class.mlb(tricode) }

    shared_examples_for "mlb team" do |tc|
      context "with #{tc}" do
        let(:tricode) { tc }
        it "returns the right team" do
          expect(subject.tricode).to eql tricode.to_sym
        end
      end
    end

    described_class.mlb_tricodes.each do |tc|
      it_behaves_like "mlb team", tc
    end
  end
end
