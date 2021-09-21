# == Schema Information
#
# Table name: matchups
#
#  id               :bigint           not null, primary key
#  sport            :integer          not null
#  year             :integer          not null, indexed => [round, conference, number]
#  round            :integer          not null, indexed => [year, conference, number]
#  conference       :integer          indexed => [year, round, number]
#  number           :integer          not null, indexed => [year, round, conference]
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
  validates :sport, inclusion: {in: %w[nba mlb]}
  validates :year, numericality: {equal_to: 2021}
  validates :round, numericality: {
    greater_than_or_equal_to: 1, less_than_or_equal_to: 4
  }
  validates :conference, inclusion: {in: %w[east west AL NL], if: -> { round < 4 }},
                       exclusion: {in: %w[east west AL NL], if: -> { round == 4 }}
  validates :number, uniqueness: {scope: %i[year round conference]},
                     numericality: {greater_than_or_equal_to: 1}
  validate do
    errors.add(:number, "must be at most #{num_matchups_for_round}") if number > num_matchups_for_round
  end
  validates :favorite_wins, :underdog_wins, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: 4
  }
  validates :games_played, numericality: {less_than_or_equal_to: 7},
                           if: ->(m) { m.favorite_wins && m.underdog_wins }
  validate do
    if favorite_tricode&.to_sym == underdog_tricode&.to_sym
      errors.add(:favorite_tricode, 'must be different than underdog')
      errors.add(:underdog_tricode, 'must be different than favorite')
    end
  end

  has_many :picks, dependent: :restrict_with_exception

  enum sport: {nba: 0, mlb: 1}
  enum conference: {east: 0, west: 1, finals: 2, AL: 3, NL: 4, WS: 5}
  enum favorite_tricode: Team.tricodes_for_enum, _prefix: :favorite
  enum underdog_tricode: Team.tricodes_for_enum, _prefix: :underdog

  scope :accepting_entries, -> { where('starts_at > ?', Time.current) }

  def favorite
    Team[favorite_tricode]
  end

  def underdog
    Team[underdog_tricode]
  end

  def finished?
    favorite_wins == 4 || underdog_wins == 4
  end

  def games_played
    favorite_wins + underdog_wins
  end

  def title
    [favorite_tricode&.upcase, underdog_tricode&.upcase].join(' v ')
  end

  def num_matchups_for_round
    case round
    when 1
      4
    when 2
      2
    else
      1
    end
  end
end
