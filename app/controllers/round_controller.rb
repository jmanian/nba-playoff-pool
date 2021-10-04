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

    @user_data = picks.group_by(&:user)
                      .transform_values { |user_picks| user_picks.index_by(&:matchup_id) }
  end
  # rubocop:enable Metrics
end
