require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /privacy_policy" do
    context '未ログイン時' do
      it '正常にアクセスできる' do
        get privacy_policy_path
        expect(response).to have_http_status(:success)
      end

      it 'プライバシーポリシーページが表示される' do
        get privacy_policy_path
        expect(response.body).to include('プライバシーポリシー')
      end

      it 'サービス概要が表示される' do
        get privacy_policy_path
        expect(response.body).to include('サービス概要')
      end

      it '収集する情報が表示される' do
        get privacy_policy_path
        expect(response.body).to include('収集する情報')
      end

      it '情報の利用目的が表示される' do
        get privacy_policy_path
        expect(response.body).to include('情報の利用目的')
      end

      it '情報の管理が表示される' do
        get privacy_policy_path
        expect(response.body).to include('情報の管理')
      end

      it '免責事項が表示される' do
        get privacy_policy_path
        expect(response.body).to include('免責事項')
      end

      it 'お問い合わせ先が表示される' do
        get privacy_policy_path
        expect(response.body).to include('お問い合わせ先')
      end
    end

    context 'ログイン時' do
      let(:user) { User.create!(email: 'test@example.com', password: 'password') }

      before { sign_in user }

      it '正常にアクセスできる' do
        get privacy_policy_path
        expect(response).to have_http_status(:success)
      end

      it 'プライバシーポリシーページが表示される' do
        get privacy_policy_path
        expect(response.body).to include('プライバシーポリシー')
      end
    end
  end

  describe "GET /terms" do
    context '未ログイン時' do
      it '正常にアクセスできる' do
        get terms_path
        expect(response).to have_http_status(:success)
      end

      it '利用規約ページが表示される' do
        get terms_path
        expect(response.body).to include('利用規約')
      end

      it 'サービスの利用条件が表示される' do
        get terms_path
        expect(response.body).to include('サービスの利用条件')
      end

      it '禁止事項が表示される' do
        get terms_path
        expect(response.body).to include('禁止事項')
      end

      it '免責事項が表示される' do
        get terms_path
        expect(response.body).to include('免責事項')
      end

      it 'アカウントの管理が表示される' do
        get terms_path
        expect(response.body).to include('アカウントの管理')
      end

      it 'サービスの変更・終了が表示される' do
        get terms_path
        expect(response.body).to include('サービスの変更・終了')
      end

      it '準拠法・管轄裁判所が表示される' do
        get terms_path
        expect(response.body).to include('準拠法・管轄裁判所')
      end

      it 'お問い合わせが表示される' do
        get terms_path
        expect(response.body).to include('お問い合わせ')
      end
    end

    context 'ログイン時' do
      let(:user) { User.create!(email: 'test@example.com', password: 'password') }

      before { sign_in user }

      it '正常にアクセスできる' do
        get terms_path
        expect(response).to have_http_status(:success)
      end

      it '利用規約ページが表示される' do
        get terms_path
        expect(response.body).to include('利用規約')
      end
    end
  end

  describe "GET /how_to_use" do
    context '未ログイン時' do
      it '正常にアクセスできる' do
        get how_to_use_path
        expect(response).to have_http_status(:success)
      end

      it '使い方ページが表示される' do
        get how_to_use_path
        expect(response.body).to include('ケハレ帖の使い方')
      end

      it 'イントロセクションが表示される' do
        get how_to_use_path
        expect(response.body).to include('今日のごはんに、小さなハレを。')
      end

      it '献立相談機能の説明が表示される' do
        get how_to_use_path
        expect(response.body).to include('献立相談機能')
      end

      it 'ハレ投稿機能の説明が表示される' do
        get how_to_use_path
        expect(response.body).to include('ハレ投稿機能')
      end

      it 'カレンダー機能の説明が表示される' do
        get how_to_use_path
        expect(response.body).to include('カレンダー機能')
      end

      it 'ポイントとレベルの説明が表示される' do
        get how_to_use_path
        expect(response.body).to include('ポイントとレベル')
      end

      it '始め方セクションが表示される' do
        get how_to_use_path
        expect(response.body).to include('始め方')
      end

      it 'FAQセクションが表示される' do
        get how_to_use_path
        expect(response.body).to include('よくある質問')
      end

      it '未ログイン時はアカウント登録ボタンが表示される' do
        get how_to_use_path
        expect(response.body).to include('アカウント登録')
      end
    end

    context 'ログイン時' do
      let(:user) { User.create!(email: 'test@example.com', password: 'password') }

      before { sign_in user }

      it '正常にアクセスできる' do
        get how_to_use_path
        expect(response).to have_http_status(:success)
      end

      it '使い方ページが表示される' do
        get how_to_use_path
        expect(response.body).to include('ケハレ帖の使い方')
      end

      it 'ログイン時は献立相談を始めるボタンが表示される' do
        get how_to_use_path
        expect(response.body).to include('献立相談を始める')
      end
    end
  end
end
