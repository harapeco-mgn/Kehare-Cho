class AddIndexesToHareEntriesAndPointTransactions < ActiveRecord::Migration[8.1]
  # algorithm: :concurrently でテーブルロックを回避（本番環境への書き込みをブロックしない）
  # disable_ddl_transaction! は :concurrently が DDL トランザクション外での実行を必要とするため
  disable_ddl_transaction!

  def change
    add_index :hare_entries, :occurred_on, algorithm: :concurrently
    add_index :hare_entries, :visibility, algorithm: :concurrently
    add_index :point_transactions, :awarded_on, algorithm: :concurrently
  end
end
