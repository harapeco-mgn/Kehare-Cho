class GenerateAiResponseJob < ApplicationJob
  queue_as :default

  # 将来のストリーミング対応向けジョブ
  # RAG コンテキストを注入してから chat.ask を実行する
  def perform(chat_id, content, user_id)
    chat = Chat.find(chat_id)
    user = User.find(user_id)

    if chat.messages.none?
      system_prompt = build_system_prompt(chat, user, content)
      chat.with_instructions(system_prompt)
    end

    chat.ask(content)
  end

private

  def build_system_prompt(chat, user, content)
    if chat.cooking_advice?
      CookingAdvicePromptBuilder.new(user: user).build
    else
      rag_context = MealRagRetriever.new(user: user, query: content).retrieve
      MealConsultationPromptBuilder.new(
        user: user,
        conversation_type: chat.conversation_type,
        rag_context: rag_context
      ).build
    end
  end
end
