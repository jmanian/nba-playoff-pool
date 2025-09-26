desc "Sync Matchups from the league API, NBA only for now"
task sync_matchups: :environment do
  case CurrentSeason.sport
  when :nba
    Sync::Nba::Matchups.run(CurrentSeason.year)
  when :mlb
    Sync::Mlb::Matchups.run(CurrentSeason.year)
  end
end
