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
  end
end
