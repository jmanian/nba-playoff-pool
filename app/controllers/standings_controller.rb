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

    @rounds = @data.map(&:second).flat_map(&:keys).uniq.sort

    @labels = @data.map { |user, _, _| user.username }

    @chart_data = @rounds.flat_map do |round_num|
      round_name = @round_names[round_num]
      user_round_scores = @data.map(&:second).map { |rs| rs[round_num] }
      mins = user_round_scores.map(&:first)
      pots = user_round_scores.map(&:second)
      if pots.any?(&:positive?)
        [
          {
            label: "#{round_name} Definite",
            backgroundColor: background_color(round_num),
            data: mins
          },
          {
            label: "#{round_name} Potential",
            backgroundColor: 'rgba(180, 183, 187)',
            data: pots
          }
        ]
      else
        [
          {
            label: round_name,
            backgroundColor: background_color(round_num),
            data: mins
          }
        ]
      end
    end
  end
  # rubocop:enable Metrics

  def background_color(round_num)
    [
      'rgba(51, 101, 138)',
      'rgba(215, 129, 106)',
      'rgba(117, 142, 79)',
      'rgba(134, 187, 216)'
    ][round_num - 1]
  end
end
