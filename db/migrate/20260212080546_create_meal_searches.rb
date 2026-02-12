class CreateMealSearches < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_searches do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :meal_mode
      t.integer :cook_context
      t.integer :required_minutes
      t.integer :genre_id
      t.integer :mood_id
      t.text :presented_candidate_names

      t.timestamps
    end
  end
end
