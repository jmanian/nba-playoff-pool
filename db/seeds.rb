# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def upsert_matchup!(sport:, year:, round:, conference:, number:, fav:, dog:, fav_wins:, dog_wins:, starts_at:)
  matchup = Matchup.find_or_initialize_by(
    sport: sport, year: year, round: round, conference: conference, number: number
  )
  matchup.update!(
    favorite_tricode: fav,
    underdog_tricode: dog,
    favorite_wins: fav_wins,
    underdog_wins: dog_wins,
    starts_at: starts_at
  )
end

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
  upsert_matchup!(
    sport: :mlb, year: 2021,
    round: round, conference: conference, number: number,
    fav: fav, dog: dog, fav_wins: fav_wins, dog_wins: dog_wins,
    starts_at: Date.new(2021, 11, 1)
  )
end

# NBA 2026 — mix of completed and in-progress series for UI testing
[
  # Round 1 East (completed)
  [1, :east, 1, :cle, :mia, 4, 1],
  [1, :east, 2, :bos, :orl, 4, 2],
  [1, :east, 3, :nyk, :det, 4, 3],
  [1, :east, 4, :mil, :ind, 1, 4],
  # Round 1 West (completed)
  [1, :west, 1, :okc, :mem, 4, 0],
  [1, :west, 2, :hou, :gsw, 4, 3],
  [1, :west, 3, :lal, :min, 1, 4],
  [1, :west, 4, :den, :lac, 4, 2],
  # Round 2 East (in progress)
  [2, :east, 1, :cle, :nyk, 2, 1],
  [2, :east, 2, :bos, :ind, 3, 2],
  # Round 2 West (in progress)
  [2, :west, 1, :okc, :den, 2, 2],
  [2, :west, 2, :hou, :min, 1, 1],
  # Conf Finals (not started)
  [3, :east, 1, :cle, :bos, 0, 0],
  [3, :west, 1, :okc, :hou, 0, 0],
  # Finals (not started)
  [4, :finals, 1, :okc, :cle, 0, 0]
].each do |round, conference, number, fav, dog, fav_wins, dog_wins|
  upsert_matchup!(
    sport: :nba, year: 2026,
    round: round, conference: conference, number: number,
    fav: fav, dog: dog, fav_wins: fav_wins, dog_wins: dog_wins,
    starts_at: Date.new(2026, 4, 19)
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
  user = User.find_or_create_by!(email: "#{username}@taarg.us") do |u|
    u.username = username
    u.password = SecureRandom.hex
  end

  Matchup.all.each do |matchup|
    user.picks.find_or_create_by!(matchup: matchup) do |p|
      p.winner_is_favorite = [true, false].sample
      p.num_games = rand(matchup.games_needed_to_win..matchup.max_games)
    end
  end
rescue ActiveRecord::RecordInvalid => e
  puts "skipping #{username}: #{e.message}"
end
