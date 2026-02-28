class AddShareTokenToHareEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :hare_entries, :share_token, :string
    add_index :hare_entries, :share_token, unique: true
  end
end
