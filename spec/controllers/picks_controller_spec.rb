require "rails_helper"
require "controller_helper"

describe PicksController, type: :controller do
  let(:user) { create :user }

  before do
    sign_in user
    stub_const("CurrentSeason::SPORT", :nba)
    stub_const("CurrentSeason::YEAR", 2022)
  end

  describe "#index" do
    before do
      matchup = create :matchup, :mlb, :started
      create :pick, user: user, matchup: matchup
    end

    context "when there are no matchups" do
      it "sets everything to empty" do
        get :index
        expect(assigns(:picks)).to eql({})
        expect(assigns(:other_matchups)).to be_empty
        expect(assigns(:accepting_picks)).to be false
        expect(assigns(:can_change_picks)).to be false
      end
    end

    context "when there are matchups" do
      let!(:accepting_entries) do
        [
          create(:matchup, CurrentSeason.sport, :accepting_entries, round: round, number: 1, **CurrentSeason.params),
          create(:matchup, CurrentSeason.sport, :accepting_entries, round: round, number: 2, starts_at: nil, **CurrentSeason.params)
        ]
      end

      context "when in the first round" do
        let(:round) { 1 }

        context "with no picks" do
          it "sets everything correctly" do
            get :index
            expect(assigns(:picks)).to eql({})
            expect(assigns(:other_matchups)).to eql(1 => accepting_entries)
            expect(assigns(:accepting_picks)).to be true
            expect(assigns(:can_change_picks)).to be false
          end
        end

        context "with some picks" do
          let!(:pick) { create :pick, user: user, matchup: accepting_entries.first }

          it "sets everything" do
            get :index
            expect(assigns(:picks)).to eql({1 => [pick]})
            expect(assigns(:other_matchups)).to eql(1 => [accepting_entries.last])
            expect(assigns(:accepting_picks)).to be true
            expect(assigns(:can_change_picks)).to be true
          end
        end

        context "with all picks" do
          let!(:picks) do
            accepting_entries.map do |m|
              create :pick, user: user, matchup: m
            end
          end

          it "sets everything" do
            get :index
            expect(assigns(:picks)).to eql({1 => picks})
            expect(assigns(:other_matchups)).to eql({})
            expect(assigns(:accepting_picks)).to be true
            expect(assigns(:can_change_picks)).to be true
          end
        end
      end

      context "when in the second round" do
        let(:round) { 2 }

        let!(:started) do
          (1..2).map do |n|
            create :matchup, CurrentSeason.sport, :started, round: 1, number: n, **CurrentSeason.params
          end
        end

        let!(:old_picks) do
          started.map do |m|
            create :pick, user: user, matchup: m
          end
        end

        context "with no picks" do
          it "sets everything correctly" do
            get :index
            expect(assigns(:picks)).to eql({1 => old_picks})
            expect(assigns(:other_matchups)).to eql(2 => accepting_entries)
            expect(assigns(:accepting_picks)).to be true
            expect(assigns(:can_change_picks)).to be false
          end
        end

        context "with some picks" do
          let!(:pick) { create :pick, user: user, matchup: accepting_entries.first }

          it "sets everything" do
            get :index
            expect(assigns(:picks)).to eql({1 => old_picks, 2 => [pick]})
            expect(assigns(:other_matchups)).to eql(2 => [accepting_entries.last])
            expect(assigns(:accepting_picks)).to be true
            expect(assigns(:can_change_picks)).to be true
          end
        end

        context "with all picks" do
          let!(:picks) do
            accepting_entries.map do |m|
              create :pick, user: user, matchup: m
            end
          end

          it "sets everything" do
            get :index
            expect(assigns(:picks)).to eql({1 => old_picks, 2 => picks})
            expect(assigns(:other_matchups)).to eql({})
            expect(assigns(:accepting_picks)).to be true
            expect(assigns(:can_change_picks)).to be true
          end
        end
      end
    end
  end

  describe "#new" do
    let!(:matchups) { (1..2).map { |n| create :matchup, :nba, :accepting_entries, year: 2022, number: n } }
    let!(:started_matchups) { (3..4).map { |n| create :matchup, :nba, :started, year: 2022, number: n } }
    let!(:wrong_sport_matchups) { (1..2).map { |n| create :matchup, :mlb, :accepting_entries, year: 2022, number: n } }

    let(:other_users) { create_list :user, 5 }
    let!(:picks) do
      ([user] + other_users).product(matchups + started_matchups + wrong_sport_matchups).map do |user, matchup|
        create :pick, user: user, matchup: matchup
      end
    end

    it "includes the matchups and picksfor the current season that are accepting entries" do
      get :new
      expect(assigns(:matchups)).to match_array(matchups)
      expect(assigns(:picks).keys).to match_array(matchups.map(&:id))
      expect(assigns(:picks).values.map(&:matchup)).to match_array(matchups)
      expect(assigns(:picks).values.map(&:user)).to all eql(user)
    end

    # it "includes the picks for the current user" do
  end
end
