module ScoringGrid
  NBA_GRID = [
    [10, 6, 4, 3, 0, 0, 0, 0].freeze,
    [6, 8, 6, 4, 1, 0, 0, 0].freeze,
    [4, 6, 8, 6, 2, 1, 0, 0].freeze,
    [3, 4, 6, 8, 4, 2, 1, 0].freeze,
    [0, 1, 2, 4, 8, 6, 4, 3].freeze,
    [0, 0, 1, 2, 6, 8, 6, 4].freeze,
    [0, 0, 0, 1, 4, 6, 8, 6].freeze,
    [0, 0, 0, 0, 3, 4, 6, 10].freeze
  ].freeze

  MLB_FIVE_GRID = [
    [9, 5, 3, 1, 0, 0].freeze,
    [5, 7, 5, 2, 1, 0].freeze,
    [3, 5, 7, 4, 2, 1].freeze,
    [1, 2, 4, 7, 5, 3].freeze,
    [0, 1, 2, 5, 7, 5].freeze,
    [0, 0, 1, 3, 5, 9].freeze
  ].freeze

  MLB_SEVEN_GRID = [
    [9, 5, 3, 2, 0, 0, 0, 0].freeze,
    [5, 7, 5, 3, 1, 0, 0, 0].freeze,
    [3, 5, 7, 5, 2, 1, 0, 0].freeze,
    [2, 3, 5, 7, 4, 2, 1, 0].freeze,
    [0, 1, 2, 4, 7, 5, 3, 2].freeze,
    [0, 0, 1, 2, 5, 7, 5, 3].freeze,
    [0, 0, 0, 1, 3, 5, 7, 5].freeze,
    [0, 0, 0, 0, 2, 3, 5, 9].freeze
    ].freeze

  def self.[](matchup)
    if matchup.mlb?
      if matchup.games_needed_to_win == 3
        MLB_FIVE_GRID
      else
        MLB_SEVEN_GRID
      end
    else
      NBA_GRID
    end
  end
end
