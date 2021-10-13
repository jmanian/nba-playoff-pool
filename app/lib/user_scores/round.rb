module UserScores
  class Round < Base
    attr_reader :picks_by_matchup_id

    def initialize(user, picks)
      super(user, picks)
      @picks_by_matchup_id = picks.index_by(&:matchup_id)
    end

    def pick_for_matchup(matchup_id)
      picks_by_matchup_id[matchup_id]
    end

    def min_total
      @min_total ||= picks.sum(&:min_points)
    end

    def potential_total
      @potential_total ||= picks.sum(&:potential_points)
    end

    def max_total
      @max_total ||= picks.sum(&:max_points)
    end

    def totals
      [min_total, potential_total, max_total]
    end
  end
end
