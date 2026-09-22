require "rails_helper"
require "controller_helper"

describe HomeController, type: :controller do
  before do
    stub_const("CurrentSeason::SPORT", :nba)
    stub_const("CurrentSeason::YEAR", 2022)
  end

  describe "#index" do
    context "when not signed in" do
      context "when no games have started" do
        it "redirects to picks" do
          get :index
          expect(response).to redirect_to("/picks")
        end
      end

      context "when games have started" do
        before { create :matchup, :nba, :started, year: 2022 }

        it "redirects to picks" do
          get :index
          expect(response).to redirect_to("/picks")
        end
      end
    end

    context "when signed in" do
      let(:user) { create :user }

      before { sign_in user }

      context "when no games have started" do
        it "redirects to picks" do
          get :index
          expect(response).to redirect_to("/picks")
        end
      end

      context "when games have started but the user has unpicked series" do
        before do
          create :matchup, :nba, :started, year: 2022, number: 1
          create :matchup, :nba, :accepting_entries, year: 2022, number: 2
        end

        it "redirects to picks" do
          get :index
          expect(response).to redirect_to("/picks")
        end
      end

      context "when games have started and the user has picked every available series" do
        let!(:started_matchup) { create :matchup, :nba, :started, year: 2022, number: 1 }
        let!(:open_matchup) { create :matchup, :nba, :accepting_entries, year: 2022, number: 2 }

        before do
          create :pick, user: user, matchup: started_matchup
          create :pick, user: user, matchup: open_matchup
        end

        it "redirects to the current season path" do
          get :index
          expect(response).to redirect_to(CurrentSeason.path)
        end
      end
    end
  end
end
