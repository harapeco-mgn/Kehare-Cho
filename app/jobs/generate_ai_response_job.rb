class GenerateAiResponseJob < ApplicationJob
  queue_as :default

  # PR5 でストリーミング + RAG 統合時に利用予定
  # 現状は MessagesController で同期的に chat.ask を呼び出している
  def perform(chat_id, content)
    chat = Chat.find(chat_id)
    chat.ask(content)
  end
end
