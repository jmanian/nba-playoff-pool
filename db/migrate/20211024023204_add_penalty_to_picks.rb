class AddPenaltyToPicks < ActiveRecord::Migration[6.1]
  def change
    add_column :picks, :penalty, :integer, null: false, default: 0
  end
end
