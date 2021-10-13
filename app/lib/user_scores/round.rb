module UserScores
  class Round
    attr_reader :user, :picks, :picks_by_matchup_id

    def self.build(picks)
      picks.group_by(&:user).map do |user, p|
        new(user, p)
      end.sort
    end

    def initialize(user, picks)
      @user = user
      @picks = picks
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

    def <=>(other)
      sort_key <=> other.sort_key
    end

    def rank_key
      sort_key.first(2)
    end

    protected

    def sort_key
      [-max_total, -min_total, user.username]
    end
  end
end
