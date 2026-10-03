require "rails_helper"

describe ColorMath do
  describe "::luminance" do
    it { expect(described_class.luminance("#000000")).to eql 0.0 }
    it { expect(described_class.luminance("#FFFFFF")).to be_within(0.0001).of(1.0) }
  end

  describe "::distance" do
    it { expect(described_class.distance("#000000", "#000000")).to eql 0.0 }
    it { expect(described_class.distance("#000000", "#030400")).to eql 5.0 }
  end

  describe "::text_color_for" do
    it { expect(described_class.text_color_for("#F58426")).to eql "#000" }
    it { expect(described_class.text_color_for("#006BB6")).to eql "#fff" }
  end
end
