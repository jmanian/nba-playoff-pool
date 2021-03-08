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
    [:nyk, 'New York', 'Knicks'],
    [:chi, 'Chicago', 'Bulls']
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
