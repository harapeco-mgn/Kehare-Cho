
 class CreateHareTags < ActiveRecord::Migration[8.1]
    def change
      create_table :hare_tags do |t|
        t.string :key, null: false
        t.string :label, null: false
        t.integer :position
        t.boolean :is_active, null: false, default: true

        t.timestamps
      end

      add_index :hare_tags, :key, unique: true
      add_index :hare_tags, :label, unique: true
      add_index :hare_tags, :position
    end
  end