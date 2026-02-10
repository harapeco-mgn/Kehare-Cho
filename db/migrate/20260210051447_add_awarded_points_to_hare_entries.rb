class AddAwardedPointsToHareEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :hare_entries, :awarded_points, :integer, default: 0, null: false
  end
end
