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
#  starts_at        :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Matchup < ApplicationRecord
  validates :sport, :year, :round, :conference, :number, :favorite_tricode, :underdog_tricode,
            :favorite_wins, :underdog_wins, :starts_at, presence: true

  validates :year, numericality: {equal_to: 2021}

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
      errors.add(:favorite_tricode, 'must be different than underdog')
      errors.add(:underdog_tricode, 'must be different than favorite')
    end
  end

  has_many :picks, dependent: :restrict_with_exception

  enum sport: {nba: 0, mlb: 1}
  enum conference: {east: 0, west: 1, finals: 2, al: 3, nl: 4, ws: 5}
  enum favorite_tricode: Team.tricodes_for_enum, _prefix: :favorite
  enum underdog_tricode: Team.tricodes_for_enum, _prefix: :underdog

  scope :accepting_entries, -> { where('starts_at > ?', Time.current) }
  scope :started, -> { where('starts_at < ?', Time.current) }

  def started?
    starts_at.past?
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

  def possible_results
    games_range = (games_needed_to_win..max_games).to_a
    [
      *games_range.map { |n| [favorite, n, "f-#{n}"] },
      *games_range.map { |n| [underdog, n, "u-#{n}"] }.reverse
    ]
  end

  def title
    [favorite_tricode&.upcase, underdog_tricode&.upcase].join(' v ')
  end

  def summary
    "#{favorite.name} (#{favorite_wins}) v #{underdog.name} (#{underdog_wins})"
  end

  def games_needed_to_win
    if mlb? && round == 1
      3
    else
      4
    end
  end

  def max_games
    (games_needed_to_win * 2) - 1
  end

  def num_rounds
    if mlb?
      3
    else
      4
    end
  end

  def num_matchups_for_round
    if nba?
      nba_matchups_for_round
    elsif mlb?
      mlb_matchups_for_round
    end
  end

  def final_round?
    round == num_rounds
  end

  def all_scores
    ScoringGrid[self]
  end

  def possible_scores
    min_index = underdog_wins
    max_index = max_games - favorite_wins

    max_index = min_index if favorite_won?
    min_index = max_index if underdog_won?

    all_scores.map do |row|
      row[min_index..max_index]
    end
  end

  def <=>(other)
    sort_key <=> other.sort_key
  end

  protected

  def sort_key
    [sport, year, round, conference_before_type_cast, number]
  end

  private

  def nba_matchups_for_round
    case round
    when 1
      4
    when 2
      2
    else
      1
    end
  end

  def mlb_matchups_for_round
    case round
    when 1
      2
    else
      1
    end
  end
end
