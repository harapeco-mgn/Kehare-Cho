require 'rails_helper'

RSpec.describe "Share::HareEntries", type: :request do
  let(:user) { create(:user) }
  let(:public_entry) { create(:hare_entry, user: user, visibility: :public_post) }
  let(:private_entry) { create(:hare_entry, user: user, visibility: :private_post) }

  describe "GET /share/hare_entries/:token" do
    context "有効な share_token の公開投稿にアクセスした場合" do
      it "認証なしで200を返すこと" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response).to have_http_status(:ok)
      end

      it "投稿本文を表示すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include(public_entry.body)
      end

      it "投稿者の display_name を表示すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include(user.display_name)
      end

      it "OGP タイトルを出力すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include('property="og:title"')
        expect(response.body).to include(user.display_name)
      end

      it "og:description を出力すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include('property="og:description"')
      end

      it "og:image にフォールバック画像を出力すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include('property="og:image"')
        # アセットフィンガープリント付き（例: ogp-abc123.png）に対応
        expect(response.body).to match(/og:image.*ogp/)
      end

      it "twitter:card を summary_large_image で出力すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include('name="twitter:card"')
        expect(response.body).to include("summary_large_image")
      end

      it "twitter:title を出力すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include('name="twitter:title"')
      end

      it "twitter:image を出力すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include('name="twitter:image"')
      end

      it "新規登録リンクを表示すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include(new_user_registration_path)
      end

      it "ログインリンクを表示すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include(new_user_session_path)
      end

      it "みんなのハレリンクを表示すること" do
        get share_hare_entry_path(public_entry.share_token)
        expect(response.body).to include(public_hare_entries_path)
      end
    end

    context "非公開投稿の share_token にアクセスした場合" do
      it "404を返すこと" do
        # 非公開投稿には share_token が生成されないため、手動でトークンを設定
        private_entry.update_column(:share_token, "private_token_xyz")
        get share_hare_entry_path("private_token_xyz")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "存在しないトークンにアクセスした場合" do
      it "404を返すこと" do
        get share_hare_entry_path("nonexistent_token_000")
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
