# == Schema Information
#
# Table name: matchups
#
#  id               :bigint           not null, primary key
#  year             :integer          not null, indexed => [round, conference, number]
#  round            :integer          not null, indexed => [year, conference, number]
#  conference       :integer          indexed => [year, round, number]
#  number           :integer          not null, indexed => [year, round, conference]
#  favorite_tricode :text             not null
#  underdog_tricode :text             not null
#  favorite_wins    :integer          default(0), not null
#  underdog_wins    :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Matchup < ApplicationRecord
  validates :year, :round, :number, :favorite_tricode, :underdog_tricode,
            :favorite_wins, :underdog_wins, presence: true
  validates :year, numericality: {equal_to: 2021}
  validates :round, numericality: {
    greater_than_or_equal_to: 1, less_than_or_equal_to: 4
  }
  validates :conference, presence: true, unless: -> { round == 4 }
  validates :favorite_tricode, :underdog_tricode, inclusion: {in: Team.tricodes}
  validates :underdog_tricode, exclusion: {in: ->(m) { [m.favorite_tricode] }}
  validates :favorite_wins, :underdog_wins, numericality: {
    greater_than_or_equal_to: 0, less_than_or_equal_to: 4
  }
  validates :games_played, numericality: {less_than_or_equal_to: 7},
                           if: ->(m) { m.favorite_wins && m.underdog_wins }

  enum conference: {east: 0, west: 1}

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
end
