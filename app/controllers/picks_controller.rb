class PicksController < ApplicationController
  before_action :authenticate_user!

  def index
    matchups = Matchup.current_season

    @picks = current_user.picks.includes(:matchup).joins(:matchup).merge(matchups)
    @other_matchups = matchups.accepting_entries
                              .where.not(id: @picks.map(&:matchup_id))
                              .order(:starts_at)
                              .group_by(&:round)

    @can_change_picks = @picks.any? { |pick| pick.matchup.accepting_entries? }
    @accepting_picks = @can_change_picks || @other_matchups.any?
    @picks = @picks.group_by { |pick| pick.matchup.round }
  end

  def new
    @matchups = Matchup.current_season.accepting_entries.order(:starts_at)
    @picks = current_user.picks.where(matchup: @matchups).index_by(&:matchup_id)
  end

  def create
    valid_matchup_ids = Matchup.current_season.accepting_entries.ids
    params.require(:pick).permit(matchup: :result).to_h[:matchup].each do |matchup_id, pick_data|
      matchup_id = matchup_id.to_i
      next unless valid_matchup_ids.include?(matchup_id)
      next if pick_data[:result].blank?

      winner_code, num_games = pick_data[:result].split('-')
      winner_is_favorite = winner_code == 'f'
      num_games = num_games.to_i

      pick = current_user.picks.find_or_initialize_by(matchup_id: matchup_id)
      pick.winner_is_favorite = winner_is_favorite
      pick.num_games = num_games
      pick.save!
    end
    redirect_to action: :index
  end
end
