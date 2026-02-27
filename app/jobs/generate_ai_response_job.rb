class GenerateAiResponseJob < ApplicationJob
  queue_as :default

  # 将来のストリーミング対応向けジョブ
  # RAG コンテキストを注入してから chat.ask を実行する
  def perform(chat_id, content, user_id)
    chat = Chat.find(chat_id)
    user = User.find(user_id)

    if chat.messages.none?
      rag_context = MealRagRetriever.new(user: user, query: content).retrieve
      system_prompt = MealConsultationPromptBuilder.new(
        user: user,
        conversation_type: chat.conversation_type,
        rag_context: rag_context
      ).build
      chat.with_instructions(system_prompt)
    end

    chat.ask(content)
  end
end
