FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@taarg.us" }
    sequence(:username) { |n| "user-#{n}" }
    password { SecureRandom.hex }
  end
end
