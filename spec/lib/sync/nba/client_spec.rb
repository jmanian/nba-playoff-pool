require "rails_helper"

RSpec.describe Sync::Nba::Client do
  describe "::fetch_bracket", :vcr do
    subject { described_class.fetch_bracket(year) }

    context "for the 2024 playoffs" do
      let(:year) { 2024 }

      it "returns the JSON from the 2023 bracket endpoint" do
        should include(:meta, :bracket)
        expect(subject[:bracket][:seasonYear]).to eql((year - 1).to_s)
      end
    end

    context "for the 2023 playoffs" do
      let(:year) { 2023 }

      it "returns the JSON from the 2022 bracket endpoint" do
        should include(:meta, :bracket)
        expect(subject[:bracket][:seasonYear]).to eql((year - 1).to_s)
      end
    end
  end
end
