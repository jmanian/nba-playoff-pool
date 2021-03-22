class PicksController < ApplicationController
  before_action :authenticate_user!

  def index
    @picks = current_user.picks.includes(:matchup)
    @other_matchups = Matchup.where(year: 2021).where.not(id: @picks.map(&:matchup_id)).accepting_entries.to_a
    @accepting_picks = Matchup.accepting_entries.exists?
    @picks = @picks.group_by { |pick| pick.matchup.round }
  end

  def new
    @matchups = Matchup.accepting_entries.order(:conference, :number)
    @picks = current_user.picks.where(matchup: @matchups).index_by(&:matchup_id)
  end

  def create
    valid_matchup_ids = Matchup.accepting_entries.ids
    params.require(:pick).permit(matchup: :result).to_h[:matchup].each do |matchup_id, pick_data|
      matchup_id = matchup_id.to_i
      next unless valid_matchup_ids.include?(matchup_id)

      result = pick_data[:result]
      pick = current_user.picks.find_or_initialize_by(matchup_id: matchup_id)
      pick.result = result
      pick.save!
    end
    redirect_to action: :index
  end
end
