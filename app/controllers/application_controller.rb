class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_all_seasons

  BG_COLORS = %w[
    not-used
    bg-primary
    bg-danger
    bg-success
    bg-warning
  ].freeze

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:username])
  end

  def load_all_seasons
    @past_seasons =
      Matchup.started
        .distinct
        .order(:sport, year: :desc)
        .pluck(:sport, :year)
        .map { |sport, year| [sport.to_sym, year] }
        .reject { |sy| sy == CurrentSeason.sport_year }
  end
end
