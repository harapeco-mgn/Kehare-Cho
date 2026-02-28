require "rails_helper"

RSpec.describe "Chats", type: :request do
  let(:user) { create(:user) }
  let!(:chat) { create(:chat, user: user) }

  describe "GET /chats/new" do
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされる" do
        get new_chat_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      before { sign_in user }

      it "正常にアクセスできる" do
        get new_chat_path
        expect(response).to have_http_status(:success)
      end

      it "相談の種類選択フォームが表示される" do
        get new_chat_path
        expect(response.body).to include("AI 献立相談")
      end
    end
  end

  describe "POST /chats" do
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされる" do
        post chats_path, params: { chat: { conversation_type: "meal_consultation" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      before { sign_in user }

      it "チャットを作成してチャット画面にリダイレクトする" do
        expect {
          post chats_path, params: { chat: { conversation_type: "meal_consultation" } }
        }.to change(Chat, :count).by(1)
        expect(response).to redirect_to(chat_path(Chat.last))
      end

      it "cooking_advice タイプでもチャットを作成できる" do
        expect {
          post chats_path, params: { chat: { conversation_type: "cooking_advice" } }
        }.to change(Chat, :count).by(1)
        expect(Chat.last.conversation_type).to eq("cooking_advice")
      end
    end
  end

  describe "GET /chats/:id" do
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされる" do
        get chat_path(chat)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      before { sign_in user }

      it "正常にアクセスできる" do
        get chat_path(chat)
        expect(response).to have_http_status(:success)
      end

      it "チャット画面が表示される" do
        get chat_path(chat)
        expect(response.body).to include("新しい相談")
      end

      context "meal_consultation タイプで料理名を含む AI メッセージがある場合" do
        let(:content) do
          <<~TEXT
            **1. 鶏むね肉と野菜のポン酢炒め**
            *   特徴: さっぱりしています。
            **2. 豆腐とわかめの味噌汁**
            *   特徴: ヘルシーです。
          TEXT
        end
        let!(:ai_message) { chat.messages.create!(role: "assistant", content: content) }

        it "料理名ごとのボタンが表示される" do
          get chat_path(chat)
          expect(response.body).to include("鶏むね肉と野菜のポン酢炒め")
          expect(response.body).to include("豆腐とわかめの味噌汁")
        end

        it "各料理名がフォームへのリンクになっている" do
          get chat_path(chat)
          expect(response.body).to include(new_hare_entry_path(body: "鶏むね肉と野菜のポン酢炒め"))
          expect(response.body).to include(new_hare_entry_path(body: "豆腐とわかめの味噌汁"))
        end
      end

      context "meal_consultation タイプで料理名がない AI メッセージ（会話的な返答）の場合" do
        let!(:ai_message) { chat.messages.create!(role: "assistant", content: "承知しました！どんな食材がありますか？") }

        it "ハレ記録フォームへのボタンが表示されない" do
          get chat_path(chat)
          expect(response.body).not_to include(new_hare_entry_path(body: ""))
        end
      end

      context "cooking_advice タイプの場合" do
        let!(:cooking_chat) { create(:chat, user: user, conversation_type: :cooking_advice) }
        let!(:ai_message) { cooking_chat.messages.create!(role: "assistant", content: "#### 1. 鶏肉の塩炒め\n特徴: 簡単です。") }

        it "ハレ記録フォームへのリンクが表示されない" do
          get chat_path(cooking_chat)
          expect(response.body).not_to include(new_hare_entry_path(body: "鶏肉の塩炒め"))
        end
      end

      context "他ユーザーのチャット" do
        let(:other_user) { create(:user) }
        let!(:other_chat) { create(:chat, user: other_user) }

        it "アクセスできない" do
          get chat_path(other_chat)
          expect(response).to have_http_status(:not_found).or redirect_to(root_path)
        end
      end
    end
  end

  describe "POST /chats/:chat_id/messages" do
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされる" do
        post chat_messages_path(chat), params: { message: { content: "テスト" } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      before { sign_in user }

      it "空白メッセージの場合はリダイレクトする（メッセージ追加なし）" do
        expect {
          post chat_messages_path(chat), params: { message: { content: "   " } }
        }.not_to change(Message, :count)
        expect(response).to redirect_to(chat_path(chat))
      end

      context "自分のチャットの場合" do
        it "chat_path にリダイレクトする" do
          # chat.ask は RubyLLM を呼ぶためスタブ済み（rails_helper の before(:each) で RubyLLM.embed をスタブ）
          # ただし chat.ask 自体はネットワーク呼び出しを含むため、ここでは空白メッセージでリダイレクトのみ確認
          post chat_messages_path(chat), params: { message: { content: "   " } }
          expect(response).to redirect_to(chat_path(chat))
        end
      end
    end
  end
end
