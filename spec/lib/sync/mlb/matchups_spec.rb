require "rails_helper"

RSpec.describe Sync::Mlb::Matchups do
  describe "::run" do
    subject { described_class.run(year) }

    let(:year) { rand(2020..2025) }
    let(:teams_data) do
      {
        teams: teams
      }
    end
    let(:teams) do
      [
        {
          id: 1,
          abbreviation: "LAD"
        },
        {
          id: 2,
          abbreviation: "NYY"
        }
      ]
    end
    let(:postseason_data) do
      {
        series: series
      }
    end
    let(:series) do
      [
        {
          data: 1
        },
        {
          data: 2
        }
      ]
    end
    let(:team_ids_to_abbreviations) do
      {
        1 => "lad",
        2 => "nyy"
      }
    end

    it "syncs all the matchups from the fetched postseason data" do
      expect(Sync::Mlb::Client).to receive(:fetch_teams).and_return(teams_data)
      expect(Sync::Mlb::Client).to receive(:fetch_postseason).with(year).and_return(postseason_data)
      series.each do |s|
        expect(described_class).to receive(:sync_matchup).with(year, s, team_ids_to_abbreviations)
      end

      subject
    end
  end

  describe "::sync_matchup" do
    subject { described_class.sync_matchup(year, series_data, team_ids_to_abbreviations) }

    let(:year) { rand(2020..2025) }
    let(:series_data) { {data: SecureRandom.hex} }
    let(:team_ids_to_abbreviations) { {1 => "lad", 2 => "nyy"} }

    it "syncs with an instance" do
      expect_any_instance_of(described_class).to receive(:sync_matchup) do |instance|
        expect(instance.instance_variable_get(:@year)).to eql(year)
        expect(instance.instance_variable_get(:@series_data)).to eql(series_data)
        expect(instance.instance_variable_get(:@team_ids_to_abbreviations)).to eql(team_ids_to_abbreviations)
      end
      subject
    end
  end

  describe "#instance_methods" do
    subject { instance }
    let(:instance) { described_class.new(year, series_data, team_ids_to_abbreviations) }
    let(:year) { 2025 }
    let(:team_ids_to_abbreviations) do
      {
        133 => "ath",
        134 => "pit",
        135 => "sd",
        136 => "sea",
        137 => "sf",
        138 => "stl",
        139 => "tb",
        140 => "tex",
        141 => "tor",
        142 => "min",
        143 => "phi",
        144 => "atl",
        145 => "cws",
        146 => "mia",
        147 => "nyy",
        158 => "mil",
        108 => "laa",
        109 => "az",
        110 => "bal",
        111 => "bos",
        112 => "chc",
        113 => "cin",
        114 => "cle",
        115 => "col",
        116 => "det",
        117 => "hou",
        118 => "kc",
        119 => "lad",
        120 => "wsh",
        121 => "nym"
      }
    end

    context "when series hasn't started and teams are unknown" do
      let(:series_data) do
        {
          series: {
            id: "F_1",
            sortNumber: 1,
            isDefault: true,
            gameType: "F"
          },
          totalItems: 3,
          totalGames: 3,
          totalGamesInProgress: 0,
          games: [
            {
              gamePk: 813072,
              gameGuid: "302be26b-38e4-4555-ad7c-b94b17ebd0eb",
              link: "/api/v1.1/game/813072/feed/live",
              gameType: "F",
              season: "2025",
              gameDate: "2025-09-30T07:33:00Z",
              officialDate: "2025-09-30",
              status: {
                abstractGameState: "Preview",
                codedGameState: "S",
                detailedState: "Scheduled",
                statusCode: "S",
                startTimeTBD: true,
                abstractGameCode: "P"
              },
              teams: {
                away: {
                  leagueRecord: {
                    wins: 0,
                    losses: 0,
                    pct: ".000"
                  },
                  team: {
                    id: 4946,
                    name: "AL Wild Card #3",
                    link: "/api/v1/teams/4946"
                  },
                  splitSquad: false,
                  seriesNumber: 1
                },
                home: {
                  leagueRecord: {
                    wins: 0,
                    losses: 0,
                    pct: ".000"
                  },
                  team: {
                    id: 4614,
                    name: "ALC1",
                    link: "/api/v1/teams/4614"
                  },
                  splitSquad: false,
                  seriesNumber: 1
                }
              },
              venue: {
                id: 3832,
                name: "AL Stadium",
                link: "/api/v1/venues/3832"
              },
              description: "AL Wild Card 'A' Game 1",
              seriesGameNumber: 1,
              seriesDescription: "Wild Card"
            },
            {
              gamePk: 813071,
              gameGuid: "fca403df-ecba-4340-b893-370ece3b6f7d",
              link: "/api/v1.1/game/813071/feed/live",
              gameType: "F",
              season: "2025",
              gameDate: "2025-10-01T07:33:00Z",
              officialDate: "2025-10-01",
              status: {
                abstractGameState: "Preview",
                codedGameState: "S",
                detailedState: "Scheduled",
                statusCode: "S",
                startTimeTBD: true,
                abstractGameCode: "P"
              },
              teams: {
                away: {
                  leagueRecord: {
                    wins: 0,
                    losses: 0,
                    pct: ".000"
                  },
                  team: {
                    id: 4946,
                    name: "AL Wild Card #3",
                    link: "/api/v1/teams/4946"
                  },
                  splitSquad: false,
                  seriesNumber: 1
                },
                home: {
                  leagueRecord: {
                    wins: 0,
                    losses: 0,
                    pct: ".000"
                  },
                  team: {
                    id: 4614,
                    name: "ALC1",
                    link: "/api/v1/teams/4614"
                  },
                  splitSquad: false,
                  seriesNumber: 1
                }
              },
              venue: {
                id: 3832,
                name: "AL Stadium",
                link: "/api/v1/venues/3832"
              },
              description: "AL Wild Card 'A' Game 2",
              seriesGameNumber: 2,
              seriesDescription: "Wild Card"
            },
            {
              gamePk: 813073,
              gameGuid: "d69c1633-4f00-4b6d-b65d-55d29989a79c",
              link: "/api/v1.1/game/813073/feed/live",
              gameType: "F",
              season: "2025",
              gameDate: "2025-10-02T07:33:00Z",
              officialDate: "2025-10-02",
              status: {
                abstractGameState: "Preview",
                codedGameState: "S",
                detailedState: "Scheduled",
                statusCode: "S",
                startTimeTBD: true,
                abstractGameCode: "P"
              },
              teams: {
                away: {
                  leagueRecord: {
                    wins: 0,
                    losses: 0,
                    pct: ".000"
                  },
                  team: {
                    id: 4946,
                    name: "AL Wild Card #3",
                    link: "/api/v1/teams/4946"
                  },
                  splitSquad: false,
                  seriesNumber: 1
                },
                home: {
                  leagueRecord: {
                    wins: 0,
                    losses: 0,
                    pct: ".000"
                  },
                  team: {
                    id: 4614,
                    name: "ALC1",
                    link: "/api/v1/teams/4614"
                  },
                  splitSquad: false,
                  seriesNumber: 1
                }
              },
              venue: {
                id: 3832,
                name: "AL Stadium",
                link: "/api/v1/venues/3832"
              },
              description: "AL Wild Card 'A' Game 3",
              seriesGameNumber: 3,
              seriesDescription: "Wild Card"
            }
          ]
        }
      end

      it "returns correct round" do
        expect(subject.send(:round)).to eq(1)
      end

      it "returns correct conference" do
        expect(subject.send(:conference)).to eq("al")
      end

      it "returns correct number" do
        expect(subject.send(:number)).to eq(1)
      end

      it "returns correct favorite_team_id" do
        expect(subject.send(:favorite_team_id)).to eq(4614)
      end

      it "returns correct favorite_tricode" do
        expect(subject.send(:favorite_tricode)).to be_nil
      end

      it "returns correct underdog_team_id" do
        expect(subject.send(:underdog_team_id)).to eq(4946)
      end

      it "returns correct underdog_tricode" do
        expect(subject.send(:underdog_tricode)).to be_nil
      end

      it "returns correct favorite_wins" do
        expect(subject.send(:favorite_wins)).to eq(0)
      end

      it "returns correct underdog_wins" do
        expect(subject.send(:underdog_wins)).to eq(0)
      end

      it "returns correct starts_at" do
        expect(subject.send(:starts_at)).to eq(Time.parse("2025-09-30T07:33:00Z"))
      end
    end
  end
end
