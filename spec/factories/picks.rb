FactoryBot.define do
  factory :pick do
    user
    matchup
    winner_is_favorite { true }
    num_games { matchup.games_needed_to_win }
  end
end
