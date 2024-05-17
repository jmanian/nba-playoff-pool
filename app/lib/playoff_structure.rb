module PlayoffStructure
  MLB_V1 = [
    {
      name: "Division Series",
      games_needed_to_win: 3,
      matchups_per_conference: 2
    },
    {
      name: "Championship Series",
      games_needed_to_win: 4,
      matchups_per_conference: 1
    },
    {
      name: "World Series",
      games_needed_to_win: 4,
      matchups_per_conference: 1
    }
  ].each(&:freeze).freeze

  MLB_V2 = [
    {
      name: "Wild Card",
      games_needed_to_win: 2,
      matchups_per_conference: 2
    },
    {
      name: "Division Series",
      games_needed_to_win: 3,
      matchups_per_conference: 2
    },
    {
      name: "Championship Series",
      games_needed_to_win: 4,
      matchups_per_conference: 1
    },
    {
      name: "World Series",
      games_needed_to_win: 4,
      matchups_per_conference: 1
    }
  ].each(&:freeze).freeze

  NBA = [
    {
      name: "First Round",
      games_needed_to_win: 4,
      matchups_per_conference: 4
    },
    {
      name: "Conf. Semifinals",
      games_needed_to_win: 4,
      matchups_per_conference: 2
    },
    {
      name: "Conf. Finals",
      games_needed_to_win: 4,
      matchups_per_conference: 1
    },
    {
      name: "Finals",
      games_needed_to_win: 4,
      matchups_per_conference: 1
    }
  ].each(&:freeze).freeze

  def self.[](matchup)
    if matchup.mlb?
      case matchup.year
      when ..2021
        MLB_V1
      when (2022..)
        MLB_V2
      end
    elsif matchup.nba?
      NBA
    end
  end
end
