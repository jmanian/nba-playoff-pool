class CreateMatchups < ActiveRecord::Migration[6.1]
  def change
    create_table :matchups do |t|
      t.integer :sport, null: false
      t.integer :year, null: false
      t.integer :round, null: false
      t.integer :conference, null: false
      t.integer :number, null: false
      t.text :favorite_tricode, null: false
      t.text :underdog_tricode, null: false
      t.integer :favorite_wins, null: false, default: 0
      t.integer :underdog_wins, null: false, default: 0
      t.datetime :starts_at, null: false
      t.timestamps
      t.index %i[sport year round conference number], unique: true, name: "index_matchups_uniquely"
    end
  end
end
