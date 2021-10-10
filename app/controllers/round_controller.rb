class RoundController < ApplicationController
  # rubocop:disable Metrics
  def show
    redirect_to :root unless Matchup.sports.keys.include?(params[:sport])

    matchups = Matchup.started
                      .where(params.permit(:sport, :year, :round))

    if matchups.empty?
      redirect_to :root
      return
    end

    picks = Pick.joins(:matchup).merge(matchups).includes(:matchup, :user)

    @matchups = picks.map(&:matchup)
                     .uniq
                     .sort

    @round_name = @matchups.first.round_name
    @num_outcomes = @matchups.first.games_needed_to_win * 2

    @user_data = picks.group_by(&:user)
                      .transform_values { |user_picks| user_picks.index_by(&:matchup_id) }
                      .sort_by { |_u, mp| [-mp.values.map(&:max_points).sum, -mp.values.map(&:min_points).sum] }

    @num_users = @user_data.length

    @matchup_data = picks.group_by(&:matchup_id)
                         .transform_values do |pps|
                           pps.group_by(&:scoring_index)
                              .transform_values(&:length)
                         end

    @bg_color = BG_COLORS[params[:round].to_i]
  end
  # rubocop:enable Metrics
end
