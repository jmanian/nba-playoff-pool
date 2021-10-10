class StandingsController < ApplicationController
  # rubocop:disable Metrics
  def index
    users = User.includes(picks: :matchup)

    @data = users.map do |user|
      picks_by_round = user.picks
                           .select { |p| p.matchup.started? }
                           .group_by { |p| p.matchup.round }

      round_scores = picks_by_round.transform_values do |picks|
        [
          picks.sum(&:min_points),
          picks.sum(&:potential_points),
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

    scores = @data.map { |_, _, totals| totals.last }
    @biggest_max_total = @data.first.last.last

    @data.map! { |user, round_scores, totals| [user, round_scores, totals, scores.index(totals.last) + 1] }

    @rounds = @data.map(&:second).flat_map(&:keys).uniq.sort

    @bg_colors = %w[
      filler
      bg-primary
      bg-danger
      bg-success
      bg-secondary
    ]
  end
  # rubocop:enable Metrics
end
