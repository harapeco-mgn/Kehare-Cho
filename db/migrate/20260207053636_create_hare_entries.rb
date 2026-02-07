class CreateHareEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :hare_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.date :occurred_on,




      null: false
      t.integer :visibility, null: false, default: 0

      t.timestamps
    end
  end
end
