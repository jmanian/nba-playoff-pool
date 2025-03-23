class Team
  attr_reader :tricode, :city, :name

  def initialize(tricode, city, name)
    @tricode = tricode
    @city = city
    @name = name
  end

  def full_name
    [city, name].join(" ")
  end

  NBA_TEAMS = [
    [:atl, "Atlanta", "Hawks"],
    [:bkn, "Brooklyn", "Nets"],
    [:bos, "Boston", "Celtics"],
    [:cha, "Charlotte", "Hornets"],
    [:chi, "Chicago", "Bulls"],
    [:cle, "Cleveland", "Cavaliers"],
    [:dal, "Dallas", "Mavericks"],
    [:den, "Denver", "Nuggets"],
    [:det, "Detroit", "Pistons"],
    [:gsw, "Golden State", "Warriors"],
    [:hou, "Houston", "Rockets"],
    [:ind, "Indiana", "Pacers"],
    [:lac, "Los Angeles", "Clippers"],
    [:lal, "Los Angeles", "Lakers"],
    [:mem, "Memphis", "Grizzlies"],
    [:mia, "Miami", "Heat"],
    [:mil, "Milwaukee", "Bucks"],
    [:min, "Minnesota", "Timberwolves"],
    [:nop, "New Orleans", "Pelicans"],
    [:nyk, "New York", "Knicks"],
    [:okc, "Oklahoma City", "Thunder"],
    [:orl, "Orlando", "Magic"],
    [:phi, "Philadelphia", "76ers"],
    [:phx, "Phoenix", "Suns"],
    [:por, "Portland", "Trail Blazers"],
    [:sac, "Sacramento", "Kings"],
    [:sas, "San Antonio", "Spurs"],
    [:tor, "Toronto", "Raptors"],
    [:uta, "Utah", "Jazz"],
    [:was, "Washington", "Wizards"]
  ].map { |tc, c, n| [tc, Team.new(tc, c, n)] }
    .to_h.with_indifferent_access

  MLB_TEAMS = [
    [:ari, "Arizona", "Diamondbacks"],
    [:atl, "Atlanta", "Barves"],
    [:bal, "Baltimore", "Orioles"],
    [:bos, "Boston", "Red Sox"],
    [:chc, "Chicago", "Cubs"],
    [:cin, "Cincinnati", "Reds"],
    [:cle, "Cleveland", "Guardians"],
    [:col, "Colorado", "Rockies"],
    [:cws, "Chicago", "White Sox"],
    [:det, "Detroit", "Tigers"],
    [:hou, "Houston", "Astros"],
    [:kc, "Kansas City", "Royals"],
    [:laa, "Los Angeles", "Angels"],
    [:lad, "Los Angeles", "Dodgers"],
    [:mia, "Miami", "Marlins"],
    [:mil, "Milwaukee", "Brewers"],
    [:min, "Minnesota", "Twins"],
    [:nym, "New York", "Mets"],
    [:nyy, "New York", "Yankees"],
    [:oak, "Oakland", "Athletics"],
    [:phi, "Philadelphia", "Phillies"],
    [:pit, "Pittsburgh", "Pirates"],
    [:sd, "San Diego", "Padres"],
    [:sea, "Seattle", "Mariners"],
    [:sf, "San Francisco", "Giants"],
    [:stl, "St. Louis", "Cardinals"],
    [:tb, "Tampa Bay", "Rays"],
    [:tex, "Texas", "Rangers"],
    [:tor, "Toronto", "Blue Jays"],
    [:wsh, "Washington", "Nationals"]
  ].to_h { |tc, c, n| [tc, Team.new(tc, c, n)] }
    .with_indifferent_access

  class << self
    def nba_tricodes
      NBA_TEAMS.keys
    end

    def mlb_tricodes
      MLB_TEAMS.keys
    end

    def tricodes_for_enum
      (nba_tricodes | mlb_tricodes)
        .index_with(&:itself)
    end

    def nba(tricode)
      NBA_TEAMS[tricode]
    end

    def mlb(tricode)
      MLB_TEAMS[tricode]
    end
  end
end
