class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat

  def create
    content = params.dig(:message, :content).to_s.strip
    return redirect_to chat_path(@chat) if content.blank?

    # 最初のメッセージ時にシステムプロンプトを設定（RAG コンテキスト注入）
    inject_system_prompt(content) if @chat.messages.none?

    # ユーザーメッセージを即時保存し、AI 応答生成をジョブにキュー投入
    @message = @chat.create_user_message(content)
    GenerateAiResponseJob.perform_later(@chat.id, current_user.id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to chat_path(@chat) }
    end
  end

private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def inject_system_prompt(content)
    system_prompt = if @chat.cooking_advice?
                      CookingAdvicePromptBuilder.new(user: current_user).build
    else
                      rag_context = MealRagRetriever.new(user: current_user, query: content).retrieve
                      MealConsultationPromptBuilder.new(
                        user: current_user,
                        conversation_type: @chat.conversation_type,
                        rag_context: rag_context
                      ).build
    end
    @chat.with_instructions(system_prompt)
  end
end
