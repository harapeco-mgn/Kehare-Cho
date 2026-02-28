class Message < ApplicationRecord
  acts_as_message tool_calls_foreign_key: :message_id
  has_many_attached :attachments

  # AIレスポンスから番号付き料理名を抽出する
  # 例: "#### 1. 鶏むね肉と野菜のポン酢炒め" → ["鶏むね肉と野菜のポン酢炒め", ...]
  def extract_dish_names
    return [] if content.blank?

    content.lines.filter_map do |line|
      match = line.match(/^[#]{1,6}\s*\d+\.\s*(.+)/)
      match[1].strip if match
    end
  end
end
