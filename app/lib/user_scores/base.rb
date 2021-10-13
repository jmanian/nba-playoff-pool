module UserScores
  class Base
    attr_reader :user, :picks
    attr_accessor :rank

    def self.build(picks)
      scores = picks.group_by(&:user).map do |user, p|
        new(user, p)
      end.sort

      ranks = scores.map(&:rank_key)

      scores.each { |s| s.rank = ranks.index(s.rank_key) + 1 }
    end

    def initialize(user, picks)
      @user = user
      @picks = picks
    end

    def <=>(other)
      sort_key <=> other.sort_key
    end

    def rank_key
      [max_total, min_total]
    end

    protected

    def sort_key
      [-max_total, -min_total, user.username.downcase]
    end
  end
end
