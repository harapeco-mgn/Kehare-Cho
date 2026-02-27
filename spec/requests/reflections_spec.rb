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

      it "AI分析の準備中メッセージが表示される" do
        get reflection_path
        expect(response.body).to include("AIによる分析を準備中です")
      end
    end
  end
end
