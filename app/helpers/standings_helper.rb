module StandingsHelper
  # Per-round endpoint colors used for rank-based bar fills. The max
  # color matches the round's tab text so the column visually ties to
  # the active tab. Kept in sync with the .bg-round-N and .round-tab-N
  # rules in standings.scss.
  ROUND_MAX_COLORS = {
    1 => "#DB4325",
    2 => "#EDA247",
    3 => "#57C4AD",
    4 => "#006164"
  }.freeze

  # Neutral low end taken from the same Kirk diverging palette
  # (visualisingdata.com, "Red-green variation #1"). Worst-rank users
  # render in cream so the best-rank color pops.
  RANK_MIN_COLOR = "#E6E1BC".freeze

  def rank_color(rank:, total_users:, round_number:)
    max_color = ROUND_MAX_COLORS[round_number] || ROUND_MAX_COLORS[1]
    return max_color if total_users <= 1

    t = 1.0 - (rank - 1.0) / (total_users - 1)
    interpolate_hex(RANK_MIN_COLOR, max_color, t)
  end

  private

  def interpolate_hex(hex_a, hex_b, t)
    a = hex_a.delete("#").scan(/../).map { |h| h.to_i(16) }
    b = hex_b.delete("#").scan(/../).map { |h| h.to_i(16) }
    rgb = a.zip(b).map { |x, y| (x + (y - x) * t).round.clamp(0, 255) }
    "rgb(#{rgb.join(", ")})"
  end
end
