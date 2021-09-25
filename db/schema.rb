# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_21_015529) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matchups", force: :cascade do |t|
    t.integer "sport", null: false
    t.integer "year", null: false
    t.integer "round", null: false
    t.integer "conference", null: false
    t.integer "number", null: false
    t.text "favorite_tricode", null: false
    t.text "underdog_tricode", null: false
    t.integer "favorite_wins", default: 0, null: false
    t.integer "underdog_wins", default: 0, null: false
    t.datetime "starts_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sport", "year", "round", "conference", "number"], name: "index_matchups_uniquely", unique: true
  end

  create_table "picks", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "matchup_id"
    t.boolean "winner_is_favorite", null: false
    t.integer "num_games", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["matchup_id"], name: "index_picks_on_matchup_id"
    t.index ["user_id", "matchup_id"], name: "index_picks_on_user_id_and_matchup_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "username", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "picks", "matchups"
  add_foreign_key "picks", "users"
end
