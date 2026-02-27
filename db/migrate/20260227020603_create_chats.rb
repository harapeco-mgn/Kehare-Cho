class CreateChats < ActiveRecord::Migration[8.1]
  def change
    create_table :chats do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :conversation_type, null: false, default: 0
      t.timestamps
    end

    add_index :chats, :conversation_type
  end
end
