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

ActiveRecord::Schema.define(version: 2021_03_06_231126) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matchups", force: :cascade do |t|
    t.integer "year", null: false
    t.integer "round", null: false
    t.integer "conference"
    t.integer "number", null: false
    t.text "favorite_tricode", null: false
    t.text "underdog_tricode", null: false
    t.integer "favorite_wins", default: 0, null: false
    t.integer "underdog_wins", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["year", "round", "conference", "number"], name: "index_matchups_on_year_and_round_and_conference_and_number", unique: true
  end

end
