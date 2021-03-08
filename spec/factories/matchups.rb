FactoryBot.define do
  factory :matchup do
    year { 2021 }
    round { 1 }
    conference { :east }
    number { 0 }
    favorite_tricode { :nyk }
    underdog_tricode { :chi }
    starts_at { 1.week.from_now }
  end
end
