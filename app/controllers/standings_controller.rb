class StandingsController < ApplicationController
  def index
    matchups = Matchup.started
      .where(params.permit(:sport, :year))

    picks = Pick.joins(:matchup).merge(matchups).includes(:matchup, :user).load

    if picks.empty?
      render "empty"
      return
    end

    # Mark all matchups as readonly to prevent accidental persistence
    picks.map(&:matchup).uniq.each(&:readonly!)

    @initial_round = params[:round]&.to_i
    # The earliest unfinished round
    @initial_round ||= picks.map(&:matchup).reject(&:finished?).map(&:round).min

    apply_simulations(picks)

    @data = UserScores::Total.build(picks)

    @biggest_max_total = @data.first&.max_total

    # Array of the relevant round integers
    @rounds = @data.flat_map { |t| t.rounds.keys }.uniq.sort

    # Hash of round numbers to names
    @round_names = picks.map(&:matchup).uniq(&:round).to_h { |m| [m.round, m.round_name] }

    @bg_colors = BG_COLORS

    @show_overall_total = @rounds.length > 1

    @rounds_data = @rounds.map do |n|
      build_round_data(n, picks)
    end

    # For each matchup, count the picks for each outcome
    @matchup_data = picks.group_by(&:matchup_id)
      .transform_values do |pps|
      pps.group_by(&:scoring_index)
        .transform_values(&:length)
        .merge(total: pps.length)
    end
  end

  def build_round_data(n, picks)
    picks = picks.select { |pick| pick.matchup.round == n }
    matchups = picks.map(&:matchup).uniq.sort
    # TODO: Improve UserScores::Total to replace this and
    # remove the redundancy.
    user_data = UserScores::Round.build(picks)

    {
      number: n,
      matchups: matchups,
      user_data: user_data,
      show_totals: matchups.length > 1,
      num_outcomes: matchups.first.games_needed_to_win * 2,
      bg_color: BG_COLORS[n]
    }
  end

  private

  def apply_simulations(picks)
    simulations = parse_simulations
    return if simulations.empty?

    matchups_by_id = picks.map(&:matchup).index_by(&:id)

    simulations.each do |matchup_id, outcome|
      matchup = matchups_by_id[matchup_id]
      next unless matchup
      next if matchup.finished?

      apply_outcome_to_matchup(matchup, outcome)
    end
  end

  def parse_simulations
    return {} unless params[:sim].is_a?(Array)

    params[:sim].each_with_object({}) do |sim_string, hash|
      id, outcome = sim_string.split(":")
      next unless id && outcome

      hash[id.to_i] = outcome
    end
  end

  def apply_outcome_to_matchup(matchup, outcome)
    # Parse outcome format: "f-5" or "u-7"
    match = outcome.match(/^([fu])-(\d+)$/)
    return unless match

    winner_is_favorite = match[1] == "f"
    num_games = match[2].to_i

    # Validate that this is a valid outcome for this matchup
    games_needed = matchup.games_needed_to_win
    max_games = matchup.max_games
    return unless num_games >= games_needed && num_games <= max_games

    # Set the wins to simulate the outcome
    if winner_is_favorite
      matchup.favorite_wins = games_needed
      matchup.underdog_wins = num_games - games_needed
    else
      matchup.underdog_wins = games_needed
      matchup.favorite_wins = num_games - games_needed
    end
  end
end
