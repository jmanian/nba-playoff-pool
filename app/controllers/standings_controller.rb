class StandingsController < ApplicationController
  before_action :authenticate_user!

  def index
    users = User.includes(picks: :matchup)

    @data = users.map do |user|
      picks = user.picks
                  .select { |p| p.matchup.started? }
                  .group_by { |p| p.matchup.round }

      round_scores = picks.transform_values do |picks|
        [
          picks.sum(&:min_points),
          picks.sum(&:max_points)
        ]
      end
      round_scores.default = [0, 0]

      totals = [
        round_scores.values.map(&:first).sum,
        round_scores.values.map(&:last).sum
      ]

      [user, round_scores, totals]
    end

    @data.sort_by! do |_, _, totals|
      # Sort first by max total and then min
      totals.map(&:-@).reverse
    end

    @rounds = @data.map(&:second).flat_map(&:keys).uniq.sort
  end
end
