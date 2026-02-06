class CreateMealCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :meal_candidates do |t|
      t.references :genre, null: false, foreign_key: true
      t.string :name, null: false
      t.string :search_hint
      t.integer :position
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end
    add_index :meal_candidates, [:genre_id, :name], unique: true
    add_index :meal_candidates, :position
  end
end
