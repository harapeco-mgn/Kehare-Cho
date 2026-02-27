class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: [ :show ]

  def new
    @chat = current_user.chats.build
  end

  def create
    @chat = current_user.chats.build(chat_params)
    if @chat.save
      redirect_to chat_path(@chat)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @messages = @chat.messages.order(:created_at)
    @message = Message.new
  end

private

  def set_chat
    @chat = current_user.chats.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:conversation_type)
  end
end
