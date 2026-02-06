class CreateGenres < ActiveRecord::Migration[8.1]
  def change
    create_table :genres do |t|
      t.string :key, null: false
      t.string :label, null: false
      t.integer :position
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end

    add_index :genres, :key, unique: true
    add_index :genres, :label, unique: true
    add_index :genres, :position
  end
end
