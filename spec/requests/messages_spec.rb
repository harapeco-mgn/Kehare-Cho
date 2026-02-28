require "rails_helper"

RSpec.describe "Messages", type: :request do
  let(:user) { create(:user) }
  let!(:chat) { create(:chat, user: user) }

  before { sign_in user }

  describe "POST /chats/:chat_id/messages" do
    context "AIがレート制限エラーを返した場合" do
      before do
        allow_any_instance_of(Chat).to receive(:ask).and_raise(RubyLLM::RateLimitError)
      end

      it "エラーページではなくチャット画面にリダイレクトする" do
        post chat_messages_path(chat), params: { message: { content: "鶏肉の保存方法は？" } }
        expect(response).to redirect_to(chat_path(chat))
      end

      it "ユーザーに分かりやすいFlashメッセージを表示する" do
        post chat_messages_path(chat), params: { message: { content: "鶏肉の保存方法は？" } }
        expect(flash[:alert]).to include("AIが混み合っています")
      end
    end
  end
end
