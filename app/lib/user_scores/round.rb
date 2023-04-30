module UserScores
  class Round < Base
    attr_reader :picks_by_matchup_id
    attr_accessor :max_possible_round_total, :biggest_matchup_max_possible

    def self.build(picks)
      scores = super(picks)

      max_possibles = picks.map(&:matchup).uniq.map(&:max_possible_points)
      biggest_matchup_max_possible = max_possibles.max
      max_possible_round_total = max_possibles.sum
      scores.each do |s|
        s.max_possible_round_total = max_possible_round_total
        s.biggest_matchup_max_possible = biggest_matchup_max_possible
      end
    end

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

    def min_total_percentage
      min_total.to_f / max_possible_round_total
    end

    def potential_total_percentage
      potential_total.to_f / max_possible_round_total
    end

    def points_tooltip
      if picks.all? { |p| p.matchup.finished? }
        "These picks received #{min_total} #{"point".pluralize(min_total)}."
      elsif potential_total.positive?
        "Based on the results so far these picks will receive #{min_total}–#{max_total} " \
          "#{"point".pluralize(max_total)}."
      else
        "Based on the results so far these picks will receive #{min_total} #{"point".pluralize(min_total)}."
      end
    end
  end
end
