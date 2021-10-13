module UserScores
  class Total
    attr_reader :user, :picks, :rounds
    attr_accessor :rank

    def self.build(picks)
      totals = picks.group_by(&:user).map do |user, p|
        new(user, p)
      end.sort

      ranks = totals.map(&:rank_key)

      totals.each { |t| t.rank = ranks.index(t.rank_key) + 1 }
    end

    def initialize(user, picks)
      @user = user
      @picks = picks
      @rounds = picks.select { |p| p.matchup.started? }
                     .group_by { |p| p.matchup.round }
                     .transform_values do |p|
                       Round.new(user, p)
                     end
      @rounds.default = OpenStruct.new(totals: [0, 0, 0])
    end

    def min_total
      @rounds.values.sum(&:min_total)
    end

    def max_total
      @rounds.values.sum(&:max_total)
    end

    def <=>(other)
      sort_key <=> other.sort_key
    end

    def rank_key
      [max_total, min_total]
    end

    protected

    def sort_key
      [-max_total, -min_total, user.username]
    end
  end
end
