class CreateMoodTags < ActiveRecord::Migration[8.1]
  def change
    create_table :mood_tags do |t|
      t.string :key, null: false
      t.string :label, null: false
      t.integer :position
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end

    add_index :mood_tags, :key, unique: true
    add_index :mood_tags, :label, unique: true
    add_index :mood_tags, :position
  end
end
