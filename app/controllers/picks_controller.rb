class PicksController < ApplicationController
  before_action :authenticate_user!

  def index
    @picks = current_user.picks.includes(:matchup)
    @other_matchups = Matchup.where(year: 2021).where.not(id: @picks.map(&:matchup_id)).accepting_entries
    @picks = @picks.group_by { |pick| pick.matchup.round }
  end

  def new
    @matchups = Matchup.accepting_entries.order(:conference, :number)
    @picks = current_user.picks.where(matchup: @matchups).index_by(&:matchup_id)
  end

  def create
    redirect_to action: :index
  end
end
