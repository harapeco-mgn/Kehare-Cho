require "rails_helper"

RSpec.describe "Messages", type: :request do
  let(:user) { create(:user) }
  let!(:chat) { create(:chat, user: user) }

  before { sign_in user }

  describe "POST /chats/:chat_id/messages" do
    context "正常なメッセージ送信" do
      before do
        # システムプロンプト生成をスタブ（外部 AI 呼び出しをスキップ）
        allow_any_instance_of(MessagesController).to receive(:inject_system_prompt)
        # 非同期ジョブの実行をスタブ（実際のキュー投入をスキップ）
        allow(GenerateAiResponseJob).to receive(:perform_later)
      end

      it "Turbo Stream でレスポンスを返す" do
        post chat_messages_path(chat), params: { message: { content: "鶏肉の保存方法は？" } },
                                       headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end

      it "GenerateAiResponseJob をキューに投入する" do
        expect(GenerateAiResponseJob).to receive(:perform_later).with(chat.id, user.id)
        post chat_messages_path(chat), params: { message: { content: "鶏肉の保存方法は？" } }
      end

      it "ユーザーメッセージをデータベースに保存する" do
        expect {
          post chat_messages_path(chat), params: { message: { content: "鶏肉の保存方法は？" } }
        }.to change { chat.messages.where(role: "user").count }.by(1)
      end
    end

    context "空のメッセージを送信した場合" do
      it "チャット画面にリダイレクトする" do
        post chat_messages_path(chat), params: { message: { content: "" } }
        expect(response).to redirect_to(chat_path(chat))
      end
    end
  end
end
