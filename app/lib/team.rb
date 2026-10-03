class Team
  attr_reader :sport, :tricode, :city, :name, :nickname, :colors, :external_id

  def initialize(sport, tricode, city:, name:, nickname: nil, colors: {}, external_id: nil)
    @sport = sport
    @tricode = tricode
    @city = city
    @name = name
    @nickname = nickname
    @colors = colors
    @external_id = external_id
  end

  def logo_url(theme: :light)
    return nil unless external_id

    dark = theme.to_sym == :dark

    case sport
    when :nba
      "https://cdn.nba.com/logos/nba/#{external_id}/primary/#{dark ? "D" : "L"}/logo.svg"
    when :mlb
      # Cap insignia rather than the primary logo: several primary logos are
      # script wordmarks that are illegible at table-cell sizes.
      "https://www.mlbstatic.com/team-logos/team-cap-on-#{dark ? "dark" : "light"}/#{external_id}.svg"
    end
  end

  # Neutrals that pad a team's two colors out to a four-color ramp.
  ROUND_COLOR_NEUTRALS = %w[#BEC0C2 #6C757D #343A40 #000000].freeze

  # Four colors, light to dark, for the champion's overall standings bars
  # (one per round). Combines the team's two colors with whichever pair of
  # neutrals keeps all four most distinguishable, so e.g. the Knicks get
  # silver, orange, blue, black, and a red-and-black team gets a grey
  # instead of a second black.
  def round_colors
    return nil if colors.empty?

    team_colors = colors.values_at(:primary, :secondary)
    neutrals = ROUND_COLOR_NEUTRALS.combination(2).max_by do |pair|
      (team_colors + pair).combination(2).map { |a, b| ColorMath.distance(a, b) }.min
    end
    (team_colors + neutrals).sort_by { |hex| -ColorMath.luminance(hex) }
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
    ari: {city: "Arizona", name: "Diamondbacks", colors: {primary: "#A71930", secondary: "#E3D4AD"}, external_id: 109},
    atl: {city: "Atlanta", name: "Barves", colors: {primary: "#CE1141", secondary: "#13274F"}, external_id: 144},
    bal: {city: "Baltimore", name: "Orioles", colors: {primary: "#DF4601", secondary: "#000000"}, external_id: 110},
    bos: {city: "Boston", name: "Red Sox", colors: {primary: "#BD3039", secondary: "#0C2340"}, external_id: 111},
    chc: {city: "Chicago", name: "Cubs", colors: {primary: "#0E3386", secondary: "#CC3433"}, external_id: 112},
    cin: {city: "Cincinnati", name: "Reds", colors: {primary: "#C6011F", secondary: "#000000"}, external_id: 113},
    cle: {city: "Cleveland", name: "Guardians", colors: {primary: "#00385D", secondary: "#E50022"}, external_id: 114},
    col: {city: "Colorado", name: "Rockies", colors: {primary: "#333366", secondary: "#C4CED4"}, external_id: 115},
    cws: {city: "Chicago", name: "White Sox", colors: {primary: "#27251F", secondary: "#C4CED4"}, external_id: 145},
    det: {city: "Detroit", name: "Tigers", colors: {primary: "#0C2340", secondary: "#FA4616"}, external_id: 116},
    hou: {city: "Houston", name: "Astros", colors: {primary: "#002D62", secondary: "#EB6E1F"}, external_id: 117},
    kc: {city: "Kansas City", name: "Royals", colors: {primary: "#004687", secondary: "#BD9B60"}, external_id: 118},
    laa: {city: "Los Angeles", name: "Angels", colors: {primary: "#BA0021", secondary: "#003263"}, external_id: 108},
    lad: {city: "Los Angeles", name: "Dodgers", colors: {primary: "#005A9C", secondary: "#EF3E42"}, external_id: 119},
    mia: {city: "Miami", name: "Marlins", colors: {primary: "#00A3E0", secondary: "#EF3340"}, external_id: 146},
    mil: {city: "Milwaukee", name: "Brewers", colors: {primary: "#12284B", secondary: "#FFC52F"}, external_id: 158},
    min: {city: "Minnesota", name: "Twins", colors: {primary: "#002B5C", secondary: "#D31145"}, external_id: 142},
    nym: {city: "New York", name: "Mets", colors: {primary: "#002D72", secondary: "#FF5910"}, external_id: 121},
    nyy: {city: "New York", name: "Yankees", colors: {primary: "#0C2340", secondary: "#C4CED3"}, external_id: 147},
    oak: {city: "Oakland", name: "Athletics", colors: {primary: "#003831", secondary: "#EFB21E"}, external_id: 133},
    phi: {city: "Philadelphia", name: "Phillies", colors: {primary: "#E81828", secondary: "#002D72"}, external_id: 143},
    pit: {city: "Pittsburgh", name: "Pirates", colors: {primary: "#27251F", secondary: "#FDB827"}, external_id: 134},
    sd: {city: "San Diego", name: "Padres", colors: {primary: "#2F241D", secondary: "#FFC425"}, external_id: 135},
    sea: {city: "Seattle", name: "Mariners", colors: {primary: "#0C2C56", secondary: "#005C5C"}, external_id: 136},
    sf: {city: "San Francisco", name: "Giants", colors: {primary: "#FD5A1E", secondary: "#27251F"}, external_id: 137},
    stl: {city: "St. Louis", name: "Cardinals", colors: {primary: "#C41E3A", secondary: "#0C2340"}, external_id: 138},
    tb: {city: "Tampa Bay", name: "Rays", colors: {primary: "#092C5C", secondary: "#8FBCE6"}, external_id: 139},
    tex: {city: "Texas", name: "Rangers", colors: {primary: "#003278", secondary: "#C0111F"}, external_id: 140},
    tor: {city: "Toronto", name: "Blue Jays", colors: {primary: "#134A8E", secondary: "#1D2D5C"}, external_id: 141},
    wsh: {city: "Washington", name: "Nationals", colors: {primary: "#AB0003", secondary: "#14225A"}, external_id: 120}
  }.freeze

  NBA_TEAMS = NBA_TEAM_DATA
    .to_h { |tc, attrs| [tc, Team.new(:nba, tc, **attrs)] }
    .with_indifferent_access

  MLB_TEAMS = MLB_TEAM_DATA
    .to_h { |tc, attrs| [tc, Team.new(:mlb, tc, **attrs)] }
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
