class Team
  attr_reader :tricode, :city, :name, :nickname

  def initialize(tricode, city, name, nickname)
    @tricode = tricode
    @city = city
    @name = name
    @nickname = nickname
  end

  def full_name
    [city, name].join(" ")
  end

  def short_name
    nickname || name
  end

  NBA_TEAMS = [
    [:atl, "Atlanta", "Hawks"],
    [:bkn, "Brooklyn", "Nets"],
    [:bos, "Boston", "Celtics"],
    [:cha, "Charlotte", "Hornets"],
    [:chi, "Chicago", "Bulls"],
    [:cle, "Cleveland", "Cavaliers", "Cavs"],
    [:dal, "Dallas", "Mavericks", "Mavs"],
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
    [:min, "Minnesota", "Timberwolves", "T'wolves"],
    [:nop, "New Orleans", "Pelicans"],
    [:nyk, "New York", "Knicks"],
    [:okc, "Oklahoma City", "Thunder"],
    [:orl, "Orlando", "Magic"],
    [:phi, "Philadelphia", "76ers"],
    [:phx, "Phoenix", "Suns"],
    [:por, "Portland", "Trail Blazers", "Blazers"],
    [:sac, "Sacramento", "Kings"],
    [:sas, "San Antonio", "Spurs"],
    [:tor, "Toronto", "Raptors"],
    [:uta, "Utah", "Jazz"],
    [:was, "Washington", "Wizards"]
  ].to_h { |tc, c, n, nn| [tc, Team.new(tc, c, n, nn)] }
    .with_indifferent_access

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
  ].to_h { |tc, c, n, nn| [tc, Team.new(tc, c, n, nn)] }
    .with_indifferent_access

  NBA_COLORS = {
    atl: {primary: "#E03A3E", secondary: "#C1D32F"},
    bkn: {primary: "#000000", secondary: "#AAAAAA"},
    bos: {primary: "#007A33", secondary: "#BA9653"},
    cha: {primary: "#1D1160", secondary: "#00788C"},
    chi: {primary: "#CE1141", secondary: "#000000"},
    cle: {primary: "#FDBB30", secondary: "#C8004A"},
    dal: {primary: "#00538C", secondary: "#002B5E"},
    den: {primary: "#FEC524", secondary: "#2E86C1"},
    det: {primary: "#C8102E", secondary: "#006BB6"},
    gsw: {primary: "#1D428A", secondary: "#FFC72C"},
    hou: {primary: "#CE1141", secondary: "#000000"},
    ind: {primary: "#002D62", secondary: "#FDBB30"},
    lac: {primary: "#C8102E", secondary: "#1D428A"},
    lal: {primary: "#552583", secondary: "#FDB927"},
    mem: {primary: "#5D76A9", secondary: "#12173F"},
    mia: {primary: "#98002E", secondary: "#F9A01B"},
    mil: {primary: "#00471B", secondary: "#EEE1C6"},
    min: {primary: "#2E9FD8", secondary: "#236192"},
    nop: {primary: "#0C2340", secondary: "#C8102E"},
    nyk: {primary: "#006BB6", secondary: "#F58426"},
    okc: {primary: "#007AC1", secondary: "#EF3B24"},
    orl: {primary: "#0077C0", secondary: "#C4CED4"},
    phi: {primary: "#006BB6", secondary: "#ED174C"},
    phx: {primary: "#1D1160", secondary: "#E56020"},
    por: {primary: "#E03A3E", secondary: "#000000"},
    sac: {primary: "#5A2D81", secondary: "#63727A"},
    sas: {primary: "#000000", secondary: "#C4CED4"},
    tor: {primary: "#CE1141", secondary: "#000000"},
    uta: {primary: "#002B5C", secondary: "#00471B"},
    was: {primary: "#002B5C", secondary: "#E31837"}
  }.with_indifferent_access

  class << self
    def nba_colors(tricode)
      NBA_COLORS[tricode]
    end

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
