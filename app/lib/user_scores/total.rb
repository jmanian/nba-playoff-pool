module UserScores
  class Total < Base
    attr_reader :rounds

    def initialize(user, picks)
      super(user, picks)

      @rounds = picks.select { |p| p.matchup.started? }
        .group_by { |p| p.matchup.round }
        .transform_values do |p|
        Round.new(user, p)
      end
      @rounds.default = OpenStruct.new(totals: [0, 0, 0])
    end

    def min_total
      @min_total ||= @rounds.values.sum(&:min_total)
    end

    def max_total
      @max_total ||= @rounds.values.sum(&:max_total)
    end
  end
end
