class AddIndexesToHareEntriesAndPointTransactions < ActiveRecord::Migration[8.1]
  def change
    add_index :hare_entries, :occurred_on
    add_index :hare_entries, :visibility
    add_index :point_transactions, :awarded_on
  end
end
