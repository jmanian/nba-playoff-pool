require "rails_helper"

describe StandingsHelper do
  describe "#round_bar_style" do
    before { assign(:round_colors, %w[#BEC0C2 #F58426 #006BB6 #000000]) }

    it "colors the bar for the round, with dark text on a light color" do
      expect(helper.round_bar_style(2)).to eql(
        "--bs-bg-opacity: 0.85; background-color: rgba(245, 132, 38, var(--bs-bg-opacity)); color: #000;"
      )
    end

    it "uses white text on a dark color, at the given opacity" do
      expect(helper.round_bar_style(3, opacity: 0.5)).to eql(
        "--bs-bg-opacity: 0.5; background-color: rgba(0, 107, 182, var(--bs-bg-opacity)); color: #fff;"
      )
    end
  end
end
