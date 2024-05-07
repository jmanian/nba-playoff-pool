class ChangeStartsAtToNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :matchups, :starts_at, true
  end
end
