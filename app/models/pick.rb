# == Schema Information
#
# Table name: picks
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           indexed => [matchup_id]
#  matchup_id :bigint           indexed, indexed => [user_id]
#  result     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Pick < ApplicationRecord
  validates :result, presence: true
  belongs_to :user
  belongs_to :matchup

  enum result: {
    f4: 0,
    f5: 1,
    f6: 2,
    f7: 3,
    u7: 4,
    u6: 5,
    u5: 6,
    u4: 7
  }

  def winner
    if f4? || f5? || f6? || f7?
      matchup.favorite
    else
      matchup.underdog
    end
  end

  def loser
    if f4? || f5? || f6? || f7?
      matchup.underdog
    else
      matchup.favorite
    end
  end

  def num_games
    result.last.to_i
  end

  def title
    "#{winner.name} in #{num_games} (#{user.title})" if persisted?
  end

  def possible_points
    matchup.possible_scores[result_before_type_cast]
  end

  def min_points
    possible_points.min
  end

  def max_points
    possible_points.max
  end
end
