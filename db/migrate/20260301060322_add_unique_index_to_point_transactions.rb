class AddUniqueIndexToPointTransactions < ActiveRecord::Migration[8.1]
  # algorithm: :concurrently でテーブルロックを回避（本番環境への書き込みをブロックしない）
  # disable_ddl_transaction! は :concurrently が DDL トランザクション外での実行を必要とするため
  disable_ddl_transaction!

  def change
    add_index :point_transactions, %i[hare_entry_id point_rule_id],
              unique: true,
              name: "index_point_transactions_on_hare_entry_and_rule",
              algorithm: :concurrently
  end
end
