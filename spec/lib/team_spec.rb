require "rails_helper"

describe Team do
  describe "#full_name" do
    subject { team.full_name }
    let(:team) { described_class::NBA_TEAMS.values.sample }
    it { should be_present }
  end

  describe "#short_name" do
    subject { team.short_name }

    context "when the team has a nickname" do
      let(:team) { described_class.nba(:cle) }
      it { should eql "Cavs" }
    end

    context "when the team does not have a nickname" do
      let(:team) { described_class.nba(:atl) }
      it { should eql "Hawks" }
    end
  end

  describe "#colors" do
    subject { team.colors }

    context "for an NBA team" do
      let(:team) { described_class.nba(:lal) }
      it { should eql({primary: "#552583", secondary: "#FDB927"}) }
    end

    context "for an MLB team (no colors defined)" do
      let(:team) { described_class.mlb(:nyy) }
      it { should eql({}) }
    end
  end

  describe "#external_id" do
    context "for an NBA team" do
      subject { described_class.nba(:nyk).external_id }
      it { should eql 1610612752 }
    end

    context "for an MLB team" do
      subject { described_class.mlb(:nyy).external_id }
      it { should be_nil }
    end
  end

  describe "#logo_url" do
    context "for an NBA team" do
      let(:team) { described_class.nba(:nyk) }

      it "defaults to the light variant" do
        expect(team.logo_url).to eql "https://cdn.nba.com/logos/nba/1610612752/primary/L/logo.svg"
      end

      it "returns the dark variant when requested" do
        expect(team.logo_url(theme: :dark)).to eql "https://cdn.nba.com/logos/nba/1610612752/primary/D/logo.svg"
      end

      it "accepts string themes" do
        expect(team.logo_url(theme: "dark")).to include "/D/"
      end
    end

    context "for an MLB team without an external_id" do
      it "returns nil" do
        expect(described_class.mlb(:nyy).logo_url).to be_nil
      end
    end
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
