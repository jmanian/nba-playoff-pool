# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Server** (requires rbenv with Ruby 3.1.7 and `eval "$(rbenv init -)"`):
```bash
bin/rails server                        # start Rails on localhost:3000
bin/webpack-dev-server                  # start JS/CSS asset pipeline (required in dev)
```

**Tests:**
```bash
bundle exec rspec                       # full suite
bundle exec rspec spec/models/pick_spec.rb                  # single file
bundle exec rspec spec/models/pick_spec.rb:42               # single example
```

**Linting:**
```bash
bundle exec standardrb                  # Ruby linter (StandardRB, based on RuboCop)
bundle exec standardrb --fix            # auto-fix
```

**Database:**
```bash
rails db:create db:migrate db:seed
heroku pg:pull DATABASE_URL nba_playoff_pool_development --app sports-pals  # pull prod data
```

**Deployment:** Heroku app is `sports-pals`. Push to Heroku or merge to main to deploy.

## Architecture

### Domain model

The app is a playoff prediction pool. Users submit **picks** before each series starts. A pick records which team wins and in how many games. Points are awarded based on a **scoring grid** (`app/lib/scoring_grid.rb`) that rewards correct predictions more heavily the harder the outcome is to predict.

Key models:
- `Matchup` — one playoff series (favorite + underdog tricodes, win counts, round/conference/year/sport). Identified by tricode enums backed by `Team`.
- `Pick` — a user's prediction for one matchup (winner_is_favorite boolean + num_games).
- `User` — Devise-backed, has username + email + admin flag.

`CurrentSeason` (`app/lib/current_season.rb`) is a module constant that sets the active sport/year. **Update `SPORT` and `YEAR` here to switch seasons.**

### Scoring pipeline

`app/lib/user_scores/` contains the scoring logic:
- `Base` — shared `build` class method that instantiates one score object per user and assigns ranks.
- `Round` — per-user scores for one playoff round. Holds `picks_by_matchup_id`, computes `min_total` (points already locked in) and `max_total` (best possible outcome).
- `Total` — aggregates `Round` scores across all rounds for the overall standings.
- `MatchupBase` — per-pick scoring, computing `min_points`, `max_points`, `potential_points`, and `scoring_index` (used for sorting).

`StandingsController#index` builds `@data` (array of `UserScores::Total`) and `@rounds_data` (array of per-round hashes). Both are passed to views. All matchup objects are marked `readonly!` to prevent accidental DB writes during simulation.

### Simulation

Users can simulate unfinished series outcomes via URL params (`sim[]=<matchup_id>:<outcome>`). The controller applies simulations in-memory on the readonly matchup objects before scoring — no DB writes occur.

### Team data

`app/lib/team.rb` defines all NBA and MLB teams as `Team` instances (tricode, city, name, nickname). `Matchup` stores tricodes as enums and exposes `favorite` / `underdog` as `Team` objects. `NBA_COLORS` maps tricodes to `{primary:, secondary:}` hex pairs used for progress bar styling.

### Frontend

- Bootstrap 5.3 + Webpacker (webpack 4). JS entry: `app/javascript/packs/application.js`.
- Custom stylesheets in `app/assets/stylesheets/` (Sprockets pipeline).
- Dark mode uses Bootstrap 5.3's `data-bs-theme="dark"` attribute on `<html>`, persisted in localStorage under key `theme`.
- Sortable table columns and simulation dropdowns are wired in `application.js` via `turbolinks:load`.

### PlayoffStructure / ScoringGrid

`app/lib/playoff_structure.rb` and `app/lib/scoring_grid.rb` define sport-specific constants (rounds, games per round, scoring tables). These are indexed by `Matchup` objects.

### Admin / sync

`rails_admin` is mounted at `/admin` for admin users. `app/lib/sync/` contains scripts for syncing matchup data from external sources.
