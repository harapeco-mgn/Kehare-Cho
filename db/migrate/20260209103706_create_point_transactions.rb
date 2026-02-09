class CreatePointTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :point_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hare_entry, null: false, foreign_key: true
      t.references :point_rule, null: false, foreign_key: true
      t.date :awarded_on, null: false
      t.integer :points, null: false

      t.timestamps
    end
  end
end
