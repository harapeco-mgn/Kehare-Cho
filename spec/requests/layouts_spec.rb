require "rails_helper"

RSpec.describe "共通レイアウト", type: :request do
  let(:user) { create(:user) }

  describe "ログイン済みユーザー" do
    before { sign_in user }

    context "全ページで共通要素が表示される" do
      it "ホームページでヘッダーとフッターが表示される" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("ホーム")
        expect(response.body).to include("カレンダー")
        expect(response.body).to include("献立相談")
        expect(response.body).to include("ハレ投稿")
        expect(response.body).to include("プロフィール")
        expect(response.body).to include("ログアウト")
        expect(response.body).to include("プライバシーポリシー")
        expect(response.body).to include("利用規約")
      end

      it "ハレ一覧ページでヘッダーとフッターが表示される" do
        get hare_entries_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("ホーム")
        expect(response.body).to include("プライバシーポリシー")
      end

      it "カレンダーページでヘッダーとフッターが表示される" do
        get calendar_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("ホーム")
        expect(response.body).to include("プライバシーポリシー")
      end

      it "プロフィールページでヘッダーとフッターが表示される" do
        get profile_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("ホーム")
        expect(response.body).to include("プライバシーポリシー")
      end
    end

    context "ヘッダーのナビゲーションリンク" do
      it "「ハレ投稿」リンクが正しいパスを指している" do
        get root_path
        expect(response.body).to include('href="/hare_entries/new"')
      end

      it "「ホーム」リンクが正しいパスを指している" do
        get hare_entries_path
        expect(response.body).to include('href="/"')
      end

      it "「カレンダー」リンクが正しいパスを指している" do
        get root_path
        expect(response.body).to include('href="/calendar"')
      end

      it "「プロフィール」リンクが正しいパスを指している" do
        get root_path
        expect(response.body).to include('href="/profile"')
      end
    end
  end

  describe "未ログインユーザー" do
    context "ホームページ（LP）" do
      it "ヘッダーが表示されない" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("ホーム")
        expect(response.body).not_to include("カレンダー")
        expect(response.body).not_to include("ハレ投稿")
      end

      it "フッターは表示される" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("プライバシーポリシー")
        expect(response.body).to include("利用規約")
      end
    end

    context "ログインページ" do
      it "ヘッダーが表示されない" do
        get new_user_session_path
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("ホーム")
        expect(response.body).not_to include("カレンダー")
      end

      it "フッターは表示される" do
        get new_user_session_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("プライバシーポリシー")
      end
    end
  end

  describe "flashメッセージの表示" do
    before { sign_in user }

    context "ハレ投稿作成時の成功メッセージ" do
      it "作成後のリダイレクトが正しく動作する" do
        post hare_entries_path, params: {
          hare_entry: {
            body: "テスト投稿",
            occurred_on: Date.current,
            visibility: "private_post"
          }
        }
        expect(response).to have_http_status(:found)
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end
    end

    context "バリデーションエラー時のメッセージ" do
      it "エラーメッセージが表示される" do
        post hare_entries_path, params: {
          hare_entry: {
            body: "",  # 空欄でバリデーションエラー
            occurred_on: Date.current,
            visibility: "private_post"
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("個のエラーが発生しました")
        expect(response.body).to include("Bodyを入力してください")
      end
    end
  end
end
