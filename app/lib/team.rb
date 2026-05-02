class Team
  attr_reader :tricode, :city, :name, :nickname, :colors, :external_id

  def initialize(tricode, city:, name:, nickname: nil, colors: {}, external_id: nil)
    @tricode = tricode
    @city = city
    @name = name
    @nickname = nickname
    @colors = colors
    @external_id = external_id
  end

  def logo_url(theme: :light)
    return nil unless external_id

    variant = (theme.to_sym == :dark) ? "D" : "L"
    "https://cdn.nba.com/logos/nba/#{external_id}/primary/#{variant}/logo.svg"
  end

  def full_name
    [city, name].join(" ")
  end

  def short_name
    nickname || name
  end

  NBA_TEAM_DATA = {
    atl: {city: "Atlanta", name: "Hawks", colors: {primary: "#E03A3E", secondary: "#C1D32F"}, external_id: 1610612737},
    bkn: {city: "Brooklyn", name: "Nets", colors: {primary: "#000000", secondary: "#AAAAAA"}, external_id: 1610612751},
    bos: {city: "Boston", name: "Celtics", colors: {primary: "#007A33", secondary: "#BA9653"}, external_id: 1610612738},
    cha: {city: "Charlotte", name: "Hornets", colors: {primary: "#1D1160", secondary: "#00788C"}, external_id: 1610612766},
    chi: {city: "Chicago", name: "Bulls", colors: {primary: "#CE1141", secondary: "#000000"}, external_id: 1610612741},
    cle: {city: "Cleveland", name: "Cavaliers", nickname: "Cavs", colors: {primary: "#FDBB30", secondary: "#C8004A"}, external_id: 1610612739},
    dal: {city: "Dallas", name: "Mavericks", nickname: "Mavs", colors: {primary: "#00538C", secondary: "#002B5E"}, external_id: 1610612742},
    den: {city: "Denver", name: "Nuggets", colors: {primary: "#FEC524", secondary: "#2E86C1"}, external_id: 1610612743},
    det: {city: "Detroit", name: "Pistons", colors: {primary: "#C8102E", secondary: "#006BB6"}, external_id: 1610612765},
    gsw: {city: "Golden State", name: "Warriors", colors: {primary: "#1D428A", secondary: "#FFC72C"}, external_id: 1610612744},
    hou: {city: "Houston", name: "Rockets", colors: {primary: "#CE1141", secondary: "#000000"}, external_id: 1610612745},
    ind: {city: "Indiana", name: "Pacers", colors: {primary: "#002D62", secondary: "#FDBB30"}, external_id: 1610612754},
    lac: {city: "Los Angeles", name: "Clippers", colors: {primary: "#C8102E", secondary: "#1D428A"}, external_id: 1610612746},
    lal: {city: "Los Angeles", name: "Lakers", colors: {primary: "#552583", secondary: "#FDB927"}, external_id: 1610612747},
    mem: {city: "Memphis", name: "Grizzlies", colors: {primary: "#5D76A9", secondary: "#12173F"}, external_id: 1610612763},
    mia: {city: "Miami", name: "Heat", colors: {primary: "#98002E", secondary: "#F9A01B"}, external_id: 1610612748},
    mil: {city: "Milwaukee", name: "Bucks", colors: {primary: "#00471B", secondary: "#EEE1C6"}, external_id: 1610612749},
    min: {city: "Minnesota", name: "Timberwolves", nickname: "T'wolves", colors: {primary: "#2E9FD8", secondary: "#236192"}, external_id: 1610612750},
    nop: {city: "New Orleans", name: "Pelicans", colors: {primary: "#0C2340", secondary: "#C8102E"}, external_id: 1610612740},
    nyk: {city: "New York", name: "Knicks", colors: {primary: "#006BB6", secondary: "#F58426"}, external_id: 1610612752},
    okc: {city: "Oklahoma City", name: "Thunder", colors: {primary: "#007AC1", secondary: "#EF3B24"}, external_id: 1610612760},
    orl: {city: "Orlando", name: "Magic", colors: {primary: "#0077C0", secondary: "#C4CED4"}, external_id: 1610612753},
    phi: {city: "Philadelphia", name: "76ers", colors: {primary: "#006BB6", secondary: "#ED174C"}, external_id: 1610612755},
    phx: {city: "Phoenix", name: "Suns", colors: {primary: "#1D1160", secondary: "#E56020"}, external_id: 1610612756},
    por: {city: "Portland", name: "Trail Blazers", nickname: "Blazers", colors: {primary: "#E03A3E", secondary: "#000000"}, external_id: 1610612757},
    sac: {city: "Sacramento", name: "Kings", colors: {primary: "#5A2D81", secondary: "#63727A"}, external_id: 1610612758},
    sas: {city: "San Antonio", name: "Spurs", colors: {primary: "#000000", secondary: "#C4CED4"}, external_id: 1610612759},
    tor: {city: "Toronto", name: "Raptors", colors: {primary: "#CE1141", secondary: "#000000"}, external_id: 1610612761},
    uta: {city: "Utah", name: "Jazz", colors: {primary: "#002B5C", secondary: "#00471B"}, external_id: 1610612762},
    was: {city: "Washington", name: "Wizards", colors: {primary: "#002B5C", secondary: "#E31837"}, external_id: 1610612764}
  }.freeze

  MLB_TEAM_DATA = {
    ari: {city: "Arizona", name: "Diamondbacks"},
    atl: {city: "Atlanta", name: "Barves"},
    bal: {city: "Baltimore", name: "Orioles"},
    bos: {city: "Boston", name: "Red Sox"},
    chc: {city: "Chicago", name: "Cubs"},
    cin: {city: "Cincinnati", name: "Reds"},
    cle: {city: "Cleveland", name: "Guardians"},
    col: {city: "Colorado", name: "Rockies"},
    cws: {city: "Chicago", name: "White Sox"},
    det: {city: "Detroit", name: "Tigers"},
    hou: {city: "Houston", name: "Astros"},
    kc: {city: "Kansas City", name: "Royals"},
    laa: {city: "Los Angeles", name: "Angels"},
    lad: {city: "Los Angeles", name: "Dodgers"},
    mia: {city: "Miami", name: "Marlins"},
    mil: {city: "Milwaukee", name: "Brewers"},
    min: {city: "Minnesota", name: "Twins"},
    nym: {city: "New York", name: "Mets"},
    nyy: {city: "New York", name: "Yankees"},
    oak: {city: "Oakland", name: "Athletics"},
    phi: {city: "Philadelphia", name: "Phillies"},
    pit: {city: "Pittsburgh", name: "Pirates"},
    sd: {city: "San Diego", name: "Padres"},
    sea: {city: "Seattle", name: "Mariners"},
    sf: {city: "San Francisco", name: "Giants"},
    stl: {city: "St. Louis", name: "Cardinals"},
    tb: {city: "Tampa Bay", name: "Rays"},
    tex: {city: "Texas", name: "Rangers"},
    tor: {city: "Toronto", name: "Blue Jays"},
    wsh: {city: "Washington", name: "Nationals"}
  }.freeze

  NBA_TEAMS = NBA_TEAM_DATA
    .to_h { |tc, attrs| [tc, Team.new(tc, **attrs)] }
    .with_indifferent_access

  MLB_TEAMS = MLB_TEAM_DATA
    .to_h { |tc, attrs| [tc, Team.new(tc, **attrs)] }
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
