require "rails_helper"

RSpec.describe "Users::Registrations", type: :request do
  describe "GET /users/sign_up" do
    it "新規登録画面が表示される" do
      get new_user_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    context "有効なパラメータの場合" do
      let(:valid_params) do
        {
          user: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "User が 1 件作成される" do
        expect {
          post user_registration_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "root_path にリダイレクトされる" do
        post user_registration_path, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it "ログイン状態になる" do
        post user_registration_path, params: valid_params
        # Devise の warden を使ってログイン状態を確認
        expect(controller.current_user).to be_present
      end
    end

    context "password_confirmation が不一致の場合" do
      let(:invalid_params) do
        {
          user: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "wrongpassword"
          }
        }
      end

      it "User は作成されない" do
        expect {
          post user_registration_path, params: invalid_params
        }.not_to change(User, :count)
      end

      it "422 が返る（再表示）" do
        post user_registration_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "既に同じ email のユーザーが存在する場合" do
      before do
        User.create!(email: "test@example.com", password: "password123", password_confirmation: "password123")
      end

      let(:duplicate_params) do
        {
          user: {
            email: "test@example.com",
            password: "password456",
            password_confirmation: "password456"
          }
        }
      end

      it "User は作成されない" do
        expect {
          post user_registration_path, params: duplicate_params
        }.not_to change(User, :count)
      end

      it "422 が返る（再表示）" do
        post user_registration_path, params: duplicate_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
