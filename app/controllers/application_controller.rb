class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :load_past_seasons

  protected

  # :nocov:
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
  # :nocov:

  def load_past_seasons
    @past_seasons =
      Matchup.started
        .distinct
        .order(:sport, year: :desc)
        .pluck(:sport, :year)
        .map { |sport, year| [sport.to_sym, year] }
        .reject { |sy| sy == CurrentSeason.sport_year }
        .group_by { |sport, year| sport }
        .transform_values { |sport_years| sport_years.map { |sport, year| year } }
  end
end
