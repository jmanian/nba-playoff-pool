desc "Sync Matchups from the league API, NBA only for now"
task sync_matchups: :environment do
  if CurrentSeason.sport == :nba
    Sync::Nba::Matchups.run(CurrentSeason.year)
  end
end
