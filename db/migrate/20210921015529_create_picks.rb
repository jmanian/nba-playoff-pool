class CreatePicks < ActiveRecord::Migration[6.1]
  def change
    create_table :picks do |t|
      t.references :user, foreign_key: true, index: false
      t.references :matchup, foreign_key: true
      t.boolean :winner_is_favorite, null: false # standard:disable Rails/ThreeStateBooleanColumn
      t.integer :num_games, null: false
      t.timestamps
      t.index %i[user_id matchup_id], unique: true
    end
  end
end
