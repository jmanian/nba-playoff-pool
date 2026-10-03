module PicksHelper
  # e.g. "Yankees lead 1–0", "Tied 1–1", "Yankees won 2–0"
  def series_status(matchup)
    fav, und = matchup.favorite_wins, matchup.underdog_wins
    leader, high, low = (fav >= und) ? [matchup.favorite, fav, und] : [matchup.underdog, und, fav]

    if matchup.finished?
      "#{leader.name} won #{high}–#{low}"
    elsif fav == und
      "Tied #{fav}–#{und}"
    else
      "#{leader.name} lead #{high}–#{low}"
    end
  end

  def pick_status_badge(matchup, pick)
    if matchup.accepting_entries?
      text = matchup.starts_at ? "Locks #{matchup.starts_at_pretty}" : "Start time TBD"
      color = pick ? "primary" : "warning"
    elsif pick.nil?
      text, color = "No pick", "secondary"
    elsif matchup.finished?
      points = "+#{pick.min_points}"
      if pick.winner_is_favorite == matchup.favorite_won? && pick.num_games == matchup.games_played
        text, color = "Exact · #{points}", "success"
      elsif pick.min_points.positive?
        text, color = points, "secondary"
      else
        text, color = points, "danger"
      end
    else
      text = (pick.min_points == pick.max_points) ? "#{pick.min_points} pts" : "#{pick.min_points}–#{pick.max_points} pts"
      color = "secondary"
    end

    tag.span(text,
      class: "badge rounded-pill text-nowrap ms-auto fw-normal bg-#{color}-subtle text-#{color}-emphasis border border-#{color}-subtle",
      title: (pick.points_tooltip if pick && matchup.started?),
      data: ({bs_toggle: "tooltip"} if pick && matchup.started?))
  end

  # e.g. "3 of 4 picked · Open", "In progress · 4 pts so far", "Final · 9 pts"
  def round_status(rows)
    points = rows.sum { |matchup, pick| (matchup.started? && pick&.min_points) || 0 }
    if rows.any? { |matchup, _| matchup.accepting_entries? }
      "#{rows.count { |_, pick| pick }} of #{rows.size} picked · Open"
    elsif rows.all? { |matchup, _| matchup.finished? }
      "Final · #{pluralize(points, "pt")}"
    else
      "In progress · #{pluralize(points, "pt")} so far"
    end
  end
end
