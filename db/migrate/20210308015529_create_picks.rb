class CreatePicks < ActiveRecord::Migration[6.1]
  def change
    create_table :picks do |t|
      t.references :user, foreign_key: true, index: false
      t.references :matchup, foreign_key: true
      t.integer :result
      t.timestamps
      t.index %i[user_id matchup_id], unique: true
    end
  end
end
