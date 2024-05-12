class StandingsController < ApplicationController
  before_action :set_round_names

  def index
    matchups = Matchup.started
      .where(params.permit(:sport, :year))

    picks = Pick.joins(:matchup).merge(matchups).includes(:matchup, :user)

    @data = UserScores::Total.build(picks)

    @biggest_max_total = @data.first&.max_total

    @rounds = @data.flat_map { |t| t.rounds.keys }.uniq.sort

    @bg_colors = BG_COLORS

    @rounds_data = @rounds.map do |n|
      build_round_data(n, picks)
    end

    # For each matchup, count the picks for each outcome
    @matchup_data = picks.group_by(&:matchup_id)
      .transform_values do |pps|
      pps.group_by(&:scoring_index)
        .transform_values(&:length)
        .merge(total: pps.length)
    end

    @show_new_rounds_interface = Rails.env.development? || current_user&.admin?
  end

  def build_round_data(n, picks)
    picks = picks.select { |pick| pick.matchup.round == n }
    matchups = picks.map(&:matchup).uniq.sort
    # TODO: Improve UserScores::Total to replace this and
    # remove the redundancy.
    user_data = UserScores::Round.build(picks)

    {
      number: n,
      matchups: matchups,
      user_data: user_data,
      show_totals: matchups.length > 1,
      num_outcomes: matchups.first.games_needed_to_win * 2,
      bg_color: BG_COLORS[n]
    }
  end
end
