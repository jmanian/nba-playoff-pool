module Sync
  class MatchupBase
    def sync_matchup
      if series_started?
        sync_wins
      elsif existing_matchup
        sync_starts_at
      elsif teams_known?
        create_matchup
      end
    end

    private

    attr_reader :year, :series_data

    def sync_wins
      matchup = existing_matchup

      if matchup
        matchup.favorite_wins = favorite_wins
        matchup.underdog_wins = underdog_wins
        matchup.save! if matchup.has_changes_to_save?

        log_update(matchup)
      end
    end

    def sync_starts_at
      matchup = existing_matchup

      if !matchup.started? && starts_at
        matchup.update!(starts_at: starts_at)
      end

      log_update(matchup)
    end

    def log_update(matchup)
      return unless matchup

      data = {id: matchup.id, changes: matchup.saved_changes.except(:updated_at)}
      Rails.logger.info("Matchup updated: #{data.to_json}")
    end

    def create_matchup
      return if existing_matchup || find_existing_reversed_matchup

      matchup = Matchup.create!(
        sport: sport,
        year: year,
        round: round,
        conference: conference,
        number: number,
        favorite_tricode: favorite_tricode,
        underdog_tricode: underdog_tricode,
        favorite_wins: favorite_wins,
        underdog_wins: underdog_wins,
        starts_at: starts_at
      )

      Rails.logger.info("Matchup created: #{matchup.attributes.except("created_at", "updated_at").to_json}")
    end

    def existing_matchup
      @existing_matchup ||=
        matchup_base.find_by(favorite_tricode: favorite_tricode, underdog_tricode: underdog_tricode)
    end

    # Just to be extra careful, this looks for a matchup where the teams are reversed.
    def find_existing_reversed_matchup
      matchup_base.find_by(favorite_tricode: underdog_tricode, underdog_tricode: favorite_tricode)
    end

    def matchup_base
      Matchup.where(sport: sport, year: year, round: round, conference: conference)
    end

    def series_started?
      favorite_wins > 0 || underdog_wins > 0
    end

    def teams_known?
      favorite_tricode && underdog_tricode
    end
  end
end
