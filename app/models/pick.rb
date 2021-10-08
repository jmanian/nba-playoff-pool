# == Schema Information
#
# Table name: picks
#
#  id                 :bigint           not null, primary key
#  user_id            :bigint           indexed => [matchup_id]
#  matchup_id         :bigint           indexed, indexed => [user_id]
#  winner_is_favorite :boolean          not null
#  num_games          :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Pick < ApplicationRecord
  validates :user_id, :matchup_id, :num_games, presence: true
  validates :winner_is_favorite, inclusion: {in: [true, false]}
  validates :num_games, numericality: {
    greater_than_or_equal_to: ->(p) { p.matchup.games_needed_to_win },
    less_than_or_equal_to: ->(p) { p.matchup.max_games }
  }

  belongs_to :user
  belongs_to :matchup

  def winner
    winner_is_favorite ? matchup.favorite : matchup.underdog
  end

  def loser
    winner_is_favorite ? matchup.underdog : matchup.favorite
  end

  def title
    "#{winner.name} in #{num_games} (#{user.title})" if persisted?
  end

  def scoring_index
    if winner_is_favorite
      num_games - matchup.games_needed_to_win
    else
      matchup.max_games + matchup.games_needed_to_win - num_games
    end
  end

  def possible_points
    matchup.possible_scores[scoring_index]
  end

  def min_points
    possible_points.min
  end

  def max_points
    possible_points.max
  end

  def potential_points
    max_points - min_points
  end

  def min_points_percentage
    min_points.to_f / matchup.max_available_points
  end

  def max_points_percentage
    max_points.to_f / matchup.max_available_points
  end

  def potential_points_percentage
    potential_points.to_f / matchup.max_available_points
  end

  def points_tooltip
    if matchup.finished?
      "This pick received #{min_points} points."
    elsif potential_points.positive?
      "Based on the results so far this pick will receive #{min_points}–#{max_points} points."
    else
      "Based on the results so far this pick will receive #{min_points} points."
    end
  end
end
