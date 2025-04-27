# == Schema Information
#
# Table name: matchups
#
#  id               :bigint           not null, primary key
#  sport            :integer          not null, indexed => [year, round, conference, number]
#  year             :integer          not null, indexed => [sport, round, conference, number]
#  round            :integer          not null, indexed => [sport, year, conference, number]
#  conference       :integer          not null, indexed => [sport, year, round, number]
#  number           :integer          not null, indexed => [sport, year, round, conference]
#  favorite_tricode :text             not null
#  underdog_tricode :text             not null
#  favorite_wins    :integer          default(0), not null
#  underdog_wins    :integer          default(0), not null
#  starts_at        :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Matchup < ApplicationRecord
  validates :sport, :year, :round, :conference, :number, :favorite_tricode, :underdog_tricode,
    :favorite_wins, :underdog_wins, presence: true

  validates :year, numericality: {greater_than_or_equal_to: 2021, less_than_or_equal_to: Date.current.year}

  validates :round, numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: ->(m) { m.num_rounds }}

  validates :conference, inclusion: {in: %w[east west], if: -> { nba? && !final_round? }}
  validates :conference, inclusion: {in: %w[finals], if: -> { nba? && final_round? }}
  validates :conference, inclusion: {in: %w[al nl], if: -> { mlb? && !final_round? }}
  validates :conference, inclusion: {in: %w[ws], if: -> { mlb? && final_round? }}

  validates :number, uniqueness: {scope: %i[sport year round conference]},
    numericality: {
      greater_than_or_equal_to: 1,
      less_than_or_equal_to: ->(m) { m.num_matchups_for_round }
    }

  validates :favorite_tricode, :underdog_tricode, inclusion: {in: Team.nba_tricodes, if: -> { nba? }}
  validates :favorite_tricode, :underdog_tricode, inclusion: {in: Team.mlb_tricodes, if: -> { mlb? }}

  validates :favorite_wins, :underdog_wins, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: ->(m) { m.games_needed_to_win }
  }
  validates :games_played, numericality: {less_than_or_equal_to: ->(m) { m.max_games }},
    if: -> { favorite_wins && underdog_wins }

  validate do
    if favorite_tricode&.to_sym == underdog_tricode&.to_sym
      errors.add(:favorite_tricode, "must be different than underdog")
      errors.add(:underdog_tricode, "must be different than favorite")
    end
  end

  has_many :picks, dependent: :restrict_with_exception

  enum sport: {nba: 0, mlb: 1}
  enum conference: {east: 0, west: 1, finals: 2, al: 3, nl: 4, ws: 5}
  enum favorite_tricode: Team.tricodes_for_enum, _prefix: :favorite
  enum underdog_tricode: Team.tricodes_for_enum, _prefix: :underdog

  scope :accepting_entries, -> { where(starts_at: Time.current...).or(where(starts_at: nil)) }
  scope :started, -> { where(starts_at: ...Time.current) }
  scope :current_season, -> { where(CurrentSeason.params) }

  def accepting_entries?
    !started?
  end

  def started?
    starts_at&.past? || false
  end

  def starts_at_pretty
    starts_at&.in_time_zone("America/New_York")
      &.strftime("%a %-d %b, %l:%M %p %Z") ||
      "?"
  end

  def favorite
    if nba?
      Team.nba(favorite_tricode)
    elsif mlb?
      Team.mlb(favorite_tricode)
    end
  end

  def underdog
    if nba?
      Team.nba(underdog_tricode)
    elsif mlb?
      Team.mlb(underdog_tricode)
    end
  end

  def favorite_won?
    favorite_wins == games_needed_to_win
  end

  def underdog_won?
    underdog_wins == games_needed_to_win
  end

  def finished?
    favorite_won? || underdog_won?
  end

  def games_played
    favorite_wins + underdog_wins
  end

  # The possible results that users can choose from for their picks,
  # with the name and form value.
  def possible_results
    games_range = (games_needed_to_win..max_games).to_a
    [
      *games_range.map { |n| ["#{favorite.name} in #{n}", "f-#{n}"] },
      *games_range.map { |n| ["#{underdog.name} in #{n}", "u-#{n}"] }.reverse
    ]
  end

  def title
    "#{round_name}: #{favorite_tricode.upcase} v #{underdog_tricode.upcase}" unless new_record?
  end

  def favorite_name_and_wins
    "#{favorite.short_name} (#{favorite_wins})"
  end

  def underdog_name_and_wins
    "#{underdog.short_name} (#{underdog_wins})"
  end

  # The overall structure of the playoffs for the sport and year
  def playoff_structure
    @playoff_structure ||= PlayoffStructure[self] || []
  end

  def round_structure
    @round_structure ||= playoff_structure[round - 1] if round
    # This fallback is for validation test cases, so that the numericality
    # tests get numbers and not nil
    @round_structure ||= Hash.new(1)
  end

  def games_needed_to_win
    round_structure[:games_needed_to_win]
  end

  def max_games
    (games_needed_to_win * 2) - 1
  end

  def num_rounds
    playoff_structure.length
  end

  def num_matchups_for_round
    round_structure[:matchups_per_conference]
  end

  def round_name
    round_structure[:name]
  end

  def final_round?
    round == num_rounds
  end

  # The entire scoring grid scaled for the round
  def all_scores
    @all_scores ||= ScoringGrid[self].map do |row|
      row.map do |s|
        s * round
      end
    end
  end

  def max_possible_points
    possible_scores.flatten.max
  end

  # The sub-matrix of the scoring grid for the remaining
  # possible outcomes, based on the series score so far.
  # When the series is over it collapses down to a single column.
  def possible_scores
    return @possible_scores if @possible_scores

    min_index = underdog_wins
    max_index = max_games - favorite_wins

    max_index = min_index if favorite_won?
    min_index = max_index if underdog_won?

    @possible_scores = all_scores.map do |row|
      row[min_index..max_index]
    end
  end

  def outcome_by_index(index)
    if index < games_needed_to_win
      winner = favorite
      num_games = index + games_needed_to_win
      possible = underdog_wins <= index
    else
      winner = underdog
      num_games = max_games + games_needed_to_win - index
      possible = favorite_wins <= max_games - index
    end
    possible &&= !finished? || num_games == games_played
    [winner, num_games, possible]
  end

  def <=>(other)
    sort_key <=> other.sort_key
  end

  protected

  def sort_key
    [sport, year, round, conference_before_type_cast, number]
  end
end
