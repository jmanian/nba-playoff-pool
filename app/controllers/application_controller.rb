class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_round_names

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

  def load_round_names
    @past_seasons = Matchup.started
                           .select(:sport, :year, :round)
                           .distinct
                           .group_by { |m| [m.sport.to_sym, m.year] }
                           .transform_values { |matchups| matchups.to_h { |m| [m.round, m.round_name] } }

    @round_names = @past_seasons.delete(CurrentSeason.sport_year)
  end
end
