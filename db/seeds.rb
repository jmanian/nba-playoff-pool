# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# MLB 2021
[
  [1, :al, 1, :tb, :bos, 1, 3],
  [1, :al, 2, :hou, :cws, 3, 1],
  [1, :nl, 1, :sf, :lad, 2, 3],
  [1, :nl, 2, :mil, :atl, 1, 3],
  [2, :al, 1, :hou, :bos, 4, 2],
  [2, :nl, 1, :atl, :lad, 4, 2],
  [3, :ws, 1, :hou, :atl, 2, 4]
].each do |round, conference, number, fav, dog, fav_wins, dog_wins|
  Matchup.find_or_create_by!(
    sport: :mlb,
    year: 2021,
    round: round,
    conference: conference,
    number: number,
    favorite_tricode: fav,
    underdog_tricode: dog,
    favorite_wins: fav_wins,
    underdog_wins: dog_wins,
    starts_at: Date.new(2021, 11, 1)
  )
end

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
  puts "skipping #{username}"
end
