require 'rails_helper'

RSpec.describe "Home", type: :request do
  let(:user) do
    User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  let(:valid_params) do
    { user: { email: "test@example.com", password: "password123" } }
  end

  describe "GET /" do
    context "未ログイン時" do
      it "LPが表示される" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("ケハレ帖")
        expect(response.body).to include("新規登録")
        expect(response.body).to include("ログイン")
      end

      it "ヘッダーとフッターは表示されない" do
        get root_path
        expect(response.body).not_to include("ログアウト")
        expect(response.body).not_to include("プライバシーポリシー")
      end
    end

    context "ログイン時" do
      before do
        user
        post user_session_path, params: valid_params
      end

      it "ホーム画面が表示される" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("ようこそ、#{user.email} さん")
        expect(response.body).to include("ケハレ帖へようこそ")
      end

      it "ヘッダーが表示される" do
        get root_path
        expect(response.body).to include("カレンダー")
        expect(response.body).to include("献立相談")
        expect(response.body).to include("ハレ投稿")
        expect(response.body).to include("プロフィール")
        expect(response.body).to include("ログアウト")
      end

      it "フッターが表示される" do
        get root_path
        expect(response.body).to include("プライバシーポリシー")
        expect(response.body).to include("2026 ケハレ帖")
      end

      it "LPの新規登録・ログインボタンは表示されない" do
        get root_path
        expect(response.body).not_to include("新規登録")
      end
    end
  end
end
