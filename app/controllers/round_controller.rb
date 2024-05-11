class RoundController < ApplicationController
  before_action :set_round_names

  def show
    redirect_to :root unless Matchup.sports.key?(params[:sport])

    matchups = Matchup.started
      .where(params.permit(:sport, :year, :round))

    if matchups.empty?
      redirect_to :root
      return
    end

    picks = Pick.joins(:matchup).merge(matchups).includes(:matchup, :user)

    matchups = picks.map(&:matchup)
      .uniq
      .sort

    user_data = UserScores::Round.build(picks)

    # For each matchup, count the picks for each outcome
    @matchup_data = picks.group_by(&:matchup_id)
      .transform_values do |pps|
      pps.group_by(&:scoring_index)
        .transform_values(&:length)
        .merge(total: pps.length)
    end

    @round_data = {
      number: params[:round].to_i,
      matchups: matchups,
      user_data: user_data,
      show_totals: matchups.length > 1,
      num_outcomes: matchups.first.games_needed_to_win * 2
    }

    @bg_color = BG_COLORS[params[:round].to_i]
  end
end
