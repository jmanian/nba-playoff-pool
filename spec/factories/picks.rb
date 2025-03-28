FactoryBot.define do
  factory :pick do
    user
    matchup
    winner_is_favorite { true }
    num_games { rand(matchup.games_needed_to_win..matchup.max_games) }
  end
end
