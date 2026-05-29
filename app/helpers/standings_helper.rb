module StandingsHelper
  # Kirk diverging palette endpoints used for the rank-based bar
  # colors in the Round Total and Overall Total columns. Interpolating
  # through the cream midpoint keeps mid-rank bars soft and neutral
  # instead of the muddy brown a direct red-to-teal lerp would land in.
  # Softer than the prior fully saturated HSL red-yellow-green gradient.
  RANK_WORST_COLOR = "#DB4325".freeze
  RANK_NEUTRAL_COLOR = "#E6E1BC".freeze
  RANK_BEST_COLOR = "#4E9150".freeze

  def rank_color(rank:, total_users:)
    return RANK_BEST_COLOR if total_users <= 1

    t = 1.0 - (rank - 1.0) / (total_users - 1)
    if t >= 0.5
      interpolate_hex(RANK_NEUTRAL_COLOR, RANK_BEST_COLOR, (t - 0.5) * 2)
    else
      interpolate_hex(RANK_WORST_COLOR, RANK_NEUTRAL_COLOR, t * 2)
    end
  end

  private

  def interpolate_hex(hex_a, hex_b, t)
    a = hex_a.delete("#").scan(/../).map { |h| h.to_i(16) }
    b = hex_b.delete("#").scan(/../).map { |h| h.to_i(16) }
    rgb = a.zip(b).map { |x, y| (x + (y - x) * t).round.clamp(0, 255) }
    "rgb(#{rgb.join(", ")})"
  end
end
