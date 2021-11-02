class RemoveNameFromComments < ActiveRecord::Migration[6.1]
  def change
    remove_column :comments, :name, :text
  end
end
