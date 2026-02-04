require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
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

  let(:invalid_params) do
    { user: { email: "test@example.com", password: "wrongpassword" } }
  end

  describe "GET /users/sign_in" do
    it "ログイン画面が表示される" do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "未ログイン時のアクセス制限" do
    it "GET /users/edit にアクセスすると /users/sign_in にリダイレクトされる" do
      get edit_user_registration_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "POST /users/sign_in" do
    context "正しい資格情報の場合" do
      before { user }

      it "root_path にリダイレクトされる" do
        post user_session_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "ログイン後に GET /users/edit が 200 を返す" do
        post user_session_path, params: valid_params
        get edit_user_registration_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "誤ったパスワードの場合" do
      before { user }

      it "ログインに失敗する" do
        post user_session_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "ログイン失敗後も GET /users/edit は /users/sign_in にリダイレクトされる" do
        post user_session_path, params: invalid_params
        get edit_user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
