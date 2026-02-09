class CreateHareEntryTags < ActiveRecord::Migration[8.1]
  def change
    create_table :hare_entry_tags do |t|
      t.references :hare_entry, null: false, foreign_key: true
      t.references :hare_tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :hare_entry_tags, [ :hare_entry_id, :hare_tag_id ], unique: true
  end
end
