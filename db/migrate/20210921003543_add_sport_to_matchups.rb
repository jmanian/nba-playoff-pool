class AddSportToMatchups < ActiveRecord::Migration[6.1]
  def change
    add_column :matchups, :sport, :integer, first: true
  end
end
