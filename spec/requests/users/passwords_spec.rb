require 'rails_helper'

RSpec.describe "Users::Passwords", type: :request do
  let(:user) do
    User.create!(
      email: "test@example.com",
      password: "old_password123",
      password_confirmation: "old_password123"
    )
  end

  before do
    ActionMailer::Base.deliveries.clear
  end

  # GET /users/password/new
  describe "GET /users/password/new" do
    it "パスワード再設定画面が表示される（200）" do
      get new_user_password_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("パスワードを忘れましたか？")
    end
  end

  # POST /users/password
  describe "POST /users/password" do
    context "存在するメールアドレスの場合" do
      it "メールが1通送信される" do
        expect {
          post user_password_path, params: { user: { email: user.email } }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "リダイレクトされる（303）" do
        post user_password_path, params: { user: { email: user.email } }
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "メール本文に reset_password_token を含む URL が含まれる" do
        post user_password_path, params: { user: { email: user.email } }

        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to eq([ user.email ])
        expect(mail.subject).to include("パスワードの再設定")
        expect(mail.body.encoded).to include("reset_password_token")
        expect(mail.body.encoded).to include("example.com/users/password/edit")
      end
    end

    context "存在しないメールアドレスの場合" do
      it "例外にならない" do
        expect {
          post user_password_path, params: { user: { email: "nonexistent@example.com" } }
        }.not_to raise_error
      end

      it "メールは送信されない" do
        expect {
          post user_password_path, params: { user: { email: "nonexistent@example.com" } }
        }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it "422 が返る" do
        post user_password_path, params: { user: { email: "nonexistent@example.com" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  # GET /users/password/edit
  describe "GET /users/password/edit" do
    context "有効なトークンの場合" do
      it "パスワード変更フォームが表示される（200）" do
        raw_token = user.send_reset_password_instructions

        get edit_user_password_path, params: { reset_password_token: raw_token }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("パスワードを変更")
      end
    end

    context "無効なトークンの場合" do
      it "フォームは表示されるがトークンエラー" do
        get edit_user_password_path, params: { reset_password_token: "invalid_token" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("パスワードを変更")
      end
    end
  end

  # PUT /users/password
  describe "PUT /users/password" do
    let(:raw_token) { user.send_reset_password_instructions }
    let(:new_password) { "new_password123" }

    context "有効なトークンと正しいパスワードの場合" do
      it "パスワードが更新される" do
        put user_password_path, params: {
          user: {
            reset_password_token: raw_token,
            password: new_password,
            password_confirmation: new_password
          }
        }

        user.reload
        expect(user.valid_password?(new_password)).to be true
      end

      it "新パスワードでログインできる" do
        put user_password_path, params: {
          user: {
            reset_password_token: raw_token,
            password: new_password,
            password_confirmation: new_password
          }
        }

        delete destroy_user_session_path

        post user_session_path, params: {
          user: { email: user.email, password: new_password }
        }

        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(root_path)
      end

      it "旧パスワードではログインできない" do
        old_password = "old_password123"

        put user_password_path, params: {
          user: {
            reset_password_token: raw_token,
            password: new_password,
            password_confirmation: new_password
          }
        }

        delete destroy_user_session_path

        post user_session_path, params: {
          user: { email: user.email, password: old_password }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("メールアドレスまたはパスワードが正しくありません")
      end
    end

    context "password_confirmation が不一致の場合" do
      it "更新に失敗し 422 が返る" do
        put user_password_path, params: {
          user: {
            reset_password_token: raw_token,
            password: new_password,
            password_confirmation: "different_password"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("パスワード（確認）とパスワードの入力が一致しません")
      end
    end

    context "無効なトークンの場合" do
      it "更新に失敗し 422 が返る" do
        put user_password_path, params: {
          user: {
            reset_password_token: "invalid_token",
            password: new_password,
            password_confirmation: new_password
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("パスワードリセット用トークンは不正な値です")
      end
    end
  end
end
