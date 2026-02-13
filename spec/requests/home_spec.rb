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

      it "ヘッダーは表示されないが、フッターは表示される" do
        get root_path
        expect(response.body).not_to include("ログアウト")
        expect(response.body).to include("プライバシーポリシー")
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
        expect(response.body).to include("こんにちは、#{user.display_name} さん")
        expect(response.body).to include("今日のごはん、何かいいことあった？")
      end

      context '今月のポイント表示' do
        let!(:hare_entry) { create(:hare_entry, user: user, occurred_on: Time.zone.today) }
        let!(:point_rule) { create(:point_rule, key: 'has_tag', points: 1, is_active: true) }
        let!(:point_transaction) do
          create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                     points: 10, awarded_on: Time.zone.today)
        end

        it '今月の合計ポイントが表示される' do
          get root_path
          expect(assigns(:monthly_points)).to eq 10
        end

        context '複数のポイントが存在する場合' do
          let!(:point_transaction2) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 20, awarded_on: Time.zone.today.beginning_of_month)
          end

          it '合計が表示される' do
            get root_path
            expect(assigns(:monthly_points)).to eq 30
          end
        end

        context '先月のポイントがある場合' do
          let!(:last_month_transaction) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 100, awarded_on: 1.month.ago)
          end

          it '今月分のみ表示される' do
            get root_path
            expect(assigns(:monthly_points)).to eq 10
          end
        end

        context 'ポイントがない場合' do
          before do
            point_transaction.destroy
          end

          it '0が表示される' do
            get root_path
            expect(assigns(:monthly_points)).to eq 0
          end
        end
      end

      context 'レベル表示' do
        let!(:hare_entry) { create(:hare_entry, user: user, occurred_on: Time.zone.today) }
        let!(:point_rule) { create(:point_rule, key: 'has_tag', points: 1, is_active: true) }

        context 'ポイントが0ptの場合' do
          it 'Lv.0が設定される' do
            get root_path
            expect(assigns(:level)).to eq 0
          end
        end

        context 'ポイントが1ptの場合' do
          let!(:point_transaction) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 1, awarded_on: Time.zone.today)
          end

          it 'Lv.1が設定される（境界値：初投稿でレベルアップ）' do
            get root_path
            expect(assigns(:level)).to eq 1
          end
        end

        context 'ポイントが10ptの場合' do
          let!(:point_transaction) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 10, awarded_on: Time.zone.today)
          end

          it 'Lv.1が設定される（境界値）' do
            get root_path
            expect(assigns(:level)).to eq 1
          end
        end

        context 'ポイントが11ptの場合' do
          let!(:point_transaction) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 11, awarded_on: Time.zone.today)
          end

          it 'Lv.2が設定される（境界値）' do
            get root_path
            expect(assigns(:level)).to eq 2
          end
        end

        context '累計ポイントから算出される' do
          let!(:point_transaction1) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 15, awarded_on: Time.zone.today)
          end
          let!(:point_transaction2) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 10, awarded_on: 1.month.ago)
          end

          it '全期間の合計（25pt）からLv.3が算出される' do
            get root_path
            expect(assigns(:level)).to eq 3
          end
        end
      end

      context '今月のハレ投稿数表示' do
        let!(:hare_entry1) { create(:hare_entry, user: user, occurred_on: Time.zone.today) }
        let!(:hare_entry2) { create(:hare_entry, user: user, occurred_on: Time.zone.today.beginning_of_month) }

        it '今月のハレ投稿数が設定される' do
          get root_path
          expect(assigns(:monthly_hare_entries_count)).to eq 2
        end

        context '先月のハレ投稿がある場合' do
          let!(:last_month_entry) do
            create(:hare_entry, user: user, occurred_on: 1.month.ago)
          end

          it '今月分のみカウントされる' do
            get root_path
            expect(assigns(:monthly_hare_entries_count)).to eq 2
          end
        end

        context 'ハレ投稿がない場合' do
          before do
            hare_entry1.destroy
            hare_entry2.destroy
          end

          it '0が設定される' do
            get root_path
            expect(assigns(:monthly_hare_entries_count)).to eq 0
          end
        end
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

      context 'ナビゲーションリンク表示' do
        before do
          get root_path
        end

        it '「記録する」リンクが存在する' do
          expect(response.body).to include('記録する')
          expect(response.body).to include(new_hare_entry_path)
        end

        it '「相談する」リンクが存在する' do
          expect(response.body).to include('相談する')
          expect(response.body).to include(new_meal_search_path)
        end

        it '「ハレ一覧」リンクが存在する' do
          expect(response.body).to include('ハレ一覧')
          expect(response.body).to include(hare_entries_path)
        end

        it '「献立ログ」リンクが存在する' do
          expect(response.body).to include('献立ログ')
          expect(response.body).to include(meal_searches_path)
        end
      end
    end
  end
end
