class Chat < ApplicationRecord
  acts_as_chat messages_foreign_key: :chat_id

  belongs_to :user
  validates :conversation_type, presence: true

  enum :conversation_type, {
    meal_consultation: 0, # 献立相談
    cooking_advice: 1,    # 料理アドバイス
    reflection: 2         # 振り返り分析
  }
end
