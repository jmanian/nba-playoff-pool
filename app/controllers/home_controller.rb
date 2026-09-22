class HomeController < ApplicationController
  def index
    matchups = Matchup.current_season

    no_games_started = !matchups.started.exists?
    has_unpicked_series = !user_signed_in? ||
      matchups.accepting_entries.where.not(id: current_user.picks.select(:matchup_id)).exists?

    if no_games_started || has_unpicked_series
      redirect_to picks_path
    else
      redirect_to CurrentSeason.path
    end
  end
end
