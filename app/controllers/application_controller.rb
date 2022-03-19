class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_all_seasons

  BG_COLORS = %w[
    filler
    bg-primary
    bg-danger
    bg-success
    bg-secondary
  ].freeze

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  def load_all_seasons
    @all_season_rounds =
      Matchup.started
             .select(:sport, :year, :round)
             .distinct
             .group_by { |m| [m.sport.to_sym, m.year] }
             .transform_values { |matchups| matchups.to_h { |m| [m.round, m.round_name] } }

    # The highest round number of the current season, for the rounds button on navbar
    @current_last_round = @all_season_rounds[CurrentSeason.sport_year]&.sort&.last&.first
    # Prior seasons and their last round number, for the past seasons navbar dropdown
    @past_seasons = @all_season_rounds.map { |sport_and_year, rounds| [*sport_and_year, rounds.keys.max] }
  end

  def set_round_names
    @round_names = @all_season_rounds[[params[:sport].to_sym, params[:year].to_i]]
  end
end
