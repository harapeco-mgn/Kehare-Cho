class CreatePointRules < ActiveRecord::Migration[8.1]
    def change
      create_table :point_rules do |t|
        t.string :key, null: false
        t.string :label, null: false
        t.integer :points, null: false
        t.json :params
        t.integer :priority, null: false
        t.boolean :is_active, null: false, default: true
        t.text :description

        t.timestamps
      end

      add_index :point_rules, :key, unique: true
      add_index :point_rules, :priority
    end
  end