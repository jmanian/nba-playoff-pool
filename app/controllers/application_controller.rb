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
    @round_names = Matchup.started
                          .where(sport: :mlb, year: 2021)
                          .distinct(:round)
                          .select(:round, :sport)
                          .map { |m| [m.round, m.round_name] }
                          .to_h
  end
end
