class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat

  def create
    content = params.dig(:message, :content).to_s.strip
    return redirect_to chat_path(@chat) if content.blank?

    # ユーザーメッセージの保存と AI 応答生成（同期）
    # PR5 でストリーミング対応時に GenerateAiResponseJob に移行予定
    @chat.ask(content)
    redirect_to chat_path(@chat)
  end

private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end
end
