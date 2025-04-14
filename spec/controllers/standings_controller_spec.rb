require "rails_helper"
require "controller_helper"

describe StandingsController, type: :controller do
  describe "#index" do
    let(:users) { create_list :user, 10 }

    let!(:other_matchups) do
      [
        create(:matchup, :nba, :accepting_entries, year: 2025, conference: "east", round: 2, number: 2),
        create(:matchup, :nba, :accepting_entries, year: 2025, conference: "west", round: 2, number: 2),
        create(:matchup, :mlb, :started, year: 2024, conference: "al", round: 1, number: 1),
        create(:matchup, :mlb, :started, year: 2024, conference: "nl", round: 1, number: 1)
      ]
    end

    let!(:other_picks) do
      users.product(other_matchups).map do |user, matchup|
        create(:pick, user: user, matchup: matchup)
      end
    end

    context "when there are no matchups to display" do
      it "renders the empty template" do
        get :index, params: {sport: "nba", year: 2025}
        expect(response).to render_template(:empty)
      end
    end

    context "when there are matchups to display" do
      let!(:matchups) do
        [
          *(1..4).flat_map do |n|
            [
              create(:matchup, :nba, :started, year: 2025, conference: "east", round: 1, number: n),
              create(:matchup, :nba, :started, year: 2025, conference: "west", round: 1, number: n)
            ]
          end,
          create(:matchup, :nba, :started, year: 2025, conference: "east", round: 2, number: 1),
          create(:matchup, :nba, :started, year: 2025, conference: "west", round: 2, number: 1)
        ]
      end

      context "but no picks" do
        it "renders the empty template" do
          get :index, params: {sport: "nba", year: 2025}
          expect(response).to render_template(:empty)
        end
      end

      context "and there are picks" do
        let!(:picks) do
          users.product(matchups).map do |user, matchup|
            create(:pick, user: user, matchup: matchup)
          end
        end

        it "renders the index template" do
          get :index, params: {sport: "nba", year: 2025}
          expect(response).to render_template(:index)
          expect(assigns(:matchup_data).keys).to match_array(matchups.map(&:id))
          expect(assigns(:rounds)).to eq([1, 2])
          expect(assigns(:data).map(&:user)).to match_array(users)
          expect(assigns(:data).flat_map(&:picks)).to match_array(picks)
          expect(assigns(:rounds_data).map { |r| r[:number] }).to eq([1, 2])
        end
      end
    end
  end
end
