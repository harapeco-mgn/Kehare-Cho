class AddFilterColumnsToMealCandidates < ActiveRecord::Migration[8.1]
  def change
    add_column :meal_candidates, :cook_context, :integer, default: 0, null: false
    add_column :meal_candidates, :minutes_max, :integer
    add_reference :meal_candidates, :mood_tag, foreign_key: true

    add_index :meal_candidates, :cook_context
    add_index :meal_candidates, :minutes_max
  end
end
