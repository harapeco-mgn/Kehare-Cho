require "rails_helper"

RSpec.describe "Reflections", type: :request do
  let(:user) { create(:user) }

  describe "GET /reflection" do
    context "未ログイン時" do
      it "ログイン画面にリダイレクトされる" do
        get reflection_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      before { sign_in user }

      it "正常にアクセスできる" do
        get reflection_path
        expect(response).to have_http_status(:success)
      end

      it "食生活レポートが表示される" do
        get reflection_path
        expect(response.body).to include("食生活レポート")
      end

      context "データが不足している場合（10日未満）" do
        it "プログレスバーが表示される" do
          get reflection_path
          expect(response.body).to include("日分記録すると分析できます")
        end
      end

      context "データが十分な場合（10日以上）" do
        before do
          10.times { |i| create(:hare_entry, user: user, occurred_on: (i + 1).days.ago) }
        end

        it "分析ボタンが表示される" do
          get reflection_path
          expect(response.body).to include("分析を生成する")
        end
      end
    end
  end

  describe "POST /reflection/analyze" do
    let(:mock_response) { double("response", content: "あなたの食生活は鶏肉中心です。") }
    let(:mock_chat) { double("chat") }

    before do
      allow(mock_chat).to receive(:with_instructions).and_return(mock_chat)
      allow(mock_chat).to receive(:ask).and_return(mock_response)
      allow(RubyLLM).to receive(:chat).and_return(mock_chat)
    end

    context "未ログイン時" do
      it "ログイン画面にリダイレクトされる" do
        post analyze_reflection_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン時" do
      before { sign_in user }

      it "正常にレスポンスを返す" do
        post analyze_reflection_path
        expect(response).to have_http_status(:success)
      end

      it "AI分析結果が表示される" do
        post analyze_reflection_path
        expect(response.body).to include("あなたの食生活は鶏肉中心です。")
      end

      it "再分析ボタンが表示される" do
        post analyze_reflection_path
        expect(response.body).to include("再分析する")
      end
    end
  end
end
