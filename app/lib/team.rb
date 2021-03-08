class Team
  attr_reader :tricode, :city, :name

  def initialize(tricode, city, name)
    @tricode = tricode
    @city = city
    @name = name
  end

  def full_name
    [city, name].join(' ')
  end

  TEAMS = [
    [:atl, 'Atlanta', 'Hawks'],
    [:bkn, 'Brooklyn', 'Nets'],
    [:bos, 'Boston', 'Celtics'],
    [:cha, 'Charlotte', 'Hornets'],
    [:chi, 'Chicago', 'Bulls'],
    [:cle, 'Cleveland', 'Cavaliers'],
    [:dal, 'Dallas', 'Mavericks'],
    [:den, 'Denver', 'Nuggets'],
    [:det, 'Detroit', 'Pistons'],
    [:gsw, 'Golden State', 'Warriors'],
    [:hou, 'Houston', 'Rockets'],
    [:ind, 'Indiana', 'Pacers'],
    [:lac, 'Los Angeles', 'Clippers'],
    [:lal, 'Los Angeles', 'Lakers'],
    [:mem, 'Memphis', 'Grizzlies'],
    [:mia, 'Miami', 'Heat'],
    [:mil, 'Milwaukee', 'Bucks'],
    [:min, 'Minnesota', 'Timberwolves'],
    [:nop, 'New Orleans', 'Pelicans'],
    [:nyk, 'New York', 'Knicks'],
    [:okc, 'Oklahoma City', 'Thunder'],
    [:orl, 'Orlando', 'Magic'],
    [:phi, 'Philadelphia', '76ers'],
    [:phx, 'Phoenix', 'Suns'],
    [:por, 'Portland', 'Trail Blazers'],
    [:sac, 'Sacramento', 'Kings'],
    [:sas, 'San Antonio', 'Spurs'],
    [:tor, 'Toronto', 'Raptors'],
    [:uta, 'Utah', 'Jazz'],
    [:was, 'Washington', 'Wizards'],
  ].map { |tc, c, n| [tc, Team.new(tc, c, n)] }
          .to_h.with_indifferent_access

  class << self
    def tricodes
      TEAMS.keys
    end

    def tricodes_for_enum
      tricodes.map { |tc| [tc, tc] }.to_h
    end

    def [](tricode)
      TEAMS[tricode]
    end
  end
end
