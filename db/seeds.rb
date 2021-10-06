# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

usernames = %w[
  alpha
  bravo
  charlie
  delta
  echo
  foxtrot
  golf
  hotel
  india
  juliet
  kilo
  lima
  mike
  november
  oscar
  papa
  quebec
  romeo
  sierra
  tango
  uniform
  victor
  whiskey
  xray
  yankee
  zulu
]

usernames.each do |username|
  user = User.create!(
    email: "#{username}@taarg.us",
    username: username,
    password: SecureRandom.hex
  )

  Matchup.all.each do |matchup|
    user.picks.create!(
      matchup: matchup,
      winner_is_favorite: [true, false].sample,
      num_games: rand(matchup.games_needed_to_win..matchup.max_games)
    )
  end
rescue ActiveRecord::RecordInvalid
  puts "skipping #{username}" # rubocop:disable Rails/Output
end
