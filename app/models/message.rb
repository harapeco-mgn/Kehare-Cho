class Message < ApplicationRecord
  acts_as_message tool_calls_foreign_key: :message_id
  has_many_attached :attachments

  # AIレスポンスから番号付き料理名を抽出する
  # 対応フォーマット:
  #   "#### 1. 料理名"     (Markdown見出し形式)
  #   "**1. 料理名**"      (太字形式)
  #   "1. **料理名**"      (番号 + 太字形式)
  def extract_dish_names
    return [] if content.blank?

    patterns = [
      /^[#]{1,6}\s*\d+\.\s*(.+)/,   # #### 1. 料理名
      /^\*\*\d+\.\s*(.+?)\*\*/,      # **1. 料理名**
      /^\d+\.\s+\*\*(.+?)\*\*/       # 1. **料理名**
    ]

    content.lines.filter_map do |line|
      stripped = line.strip
      matched = patterns.lazy.filter_map { |pattern| stripped.match(pattern) }.first
      matched ? matched[1].strip : nil
    end
  end
end
