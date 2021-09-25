FactoryBot.define do
  factory :matchup do
    sport { :nba }
    year { 2021 }
    round { 1 }
    conference { :east }
    number { 1 }
    favorite_tricode { :nyk }
    underdog_tricode { :chi }
    starts_at { 1.week.from_now }

    trait :nba

    trait :mlb do
      sport { :mlb }
      year { 2021 }
      round { 1 }
      conference { :al }
      number { 1 }
      favorite_tricode { :nyy }
      underdog_tricode { :chc }
      starts_at { 1.week.from_now }
    end

    trait :seven_games

    trait :five_games do
      mlb
      round { 1 }
    end
  end
end
