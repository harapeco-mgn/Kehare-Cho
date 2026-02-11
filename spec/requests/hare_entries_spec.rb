require 'rails_helper'

RSpec.describe "HareEntries", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }

  describe "GET /hare_entries/new" do
    context '未ログイン時' do
      it 'ログイン画面にリダイレクトされる' do
        get new_hare_entry_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      it '正常にアクセスできる' do
        get new_hare_entry_path
        expect(response).to have_http_status(:success)
      end

      it '新規HareEntryフォームが表示される' do
        get new_hare_entry_path
        expect(response.body).to include('ハレの記録を作成')
      end

      context 'タグが存在する場合' do
        let!(:active_tag) { create(:hare_tag, key: 'active', label: 'アクティブタグ', is_active: true, position: 1) }
        let!(:inactive_tag) { create(:hare_tag, key: 'inactive', label: '非アクティブタグ', is_active: false, position: 2) }

        it 'アクティブなタグがチェックボックスとして表示される' do
          get new_hare_entry_path
          expect(response.body).to include('アクティブタグ')
        end

        it '非アクティブなタグは表示されない' do
          get new_hare_entry_path
          expect(response.body).not_to include('非アクティブタグ')
        end
      end

      it 'ホームへの導線が維持されている' do
        get new_hare_entry_path
        expect(response.body).to include('href="/"')
      end
    end
  end

  describe "GET /hare_entries/:id" do
    context '未ログイン時' do
      let!(:entry) { HareEntry.create!(user: user, body: 'テスト投稿', occurred_on: Date.today, visibility: 'private_post') }

      it 'ログイン画面にリダイレクトされる' do
        get hare_entry_path(entry)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      context '自分の投稿の場合' do
        let!(:entry) { HareEntry.create!(user: user, body: 'マイ投稿の内容', occurred_on: Date.today, visibility: 'public_post') }

        it '正常にアクセスできる' do
          get hare_entry_path(entry)
          expect(response).to have_http_status(:success)
        end

        it '投稿の内容が表示される' do
          get hare_entry_path(entry)
          expect(response.body).to include('マイ投稿の内容')
        end

        it '投稿日が表示される' do
          get hare_entry_path(entry)
          expect(response.body).to include(entry.occurred_on.strftime('%Y年%-m月%-d日'))
        end

        it '公開範囲が表示される' do
          get hare_entry_path(entry)
          expect(response.body).to include('公開')
        end

        it 'ヘッダーにホームへのリンクが表示される' do
          get hare_entry_path(entry)
          expect(response.body).to include('ホーム')
          expect(response.body).to match(%r{<a[^>]*href="#{Regexp.escape(root_path)}"[^>]*>ホーム</a>})
        end

        it '編集リンクが表示される' do
          get hare_entry_path(entry)
          expect(response.body).to include('編集')
          expect(response.body).to include(edit_hare_entry_path(entry))
        end
      end

      context '他ユーザーの投稿の場合' do
        let(:other_user) { User.create!(email: 'other@example.com', password: 'password') }
        let!(:other_entry) { HareEntry.create!(user: other_user, body: '他人の投稿', occurred_on: Date.today, visibility: 'public_post') }

        it '404エラーになる' do
          get hare_entry_path(other_entry)
          expect(response).to have_http_status(:not_found)
        end
      end

      context '存在しないIDの場合' do
        it '404エラーになる' do
          get hare_entry_path(id: 99999)
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "GET /hare_entries" do
    context '未ログイン時' do
      it 'ログイン画面にリダイレクトされる' do
        get hare_entries_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      context '投稿がある場合' do
        let!(:entry1) { HareEntry.create!(user: user, body: '最初の投稿', occurred_on: 2.days.ago, visibility: 'private_post') }
        let!(:entry2) { HareEntry.create!(user: user, body: '2番目の投稿', occurred_on: 1.day.ago, visibility: 'public_post') }
        let!(:entry3) { HareEntry.create!(user: user, body: '最新の投稿', occurred_on: Date.today, visibility: 'public_post') }

        it '正常にアクセスできる' do
          get hare_entries_path
          expect(response).to have_http_status(:success)
        end

        it '自分の投稿が表示される' do
          get hare_entries_path
          expect(response.body).to include('最初の投稿')
          expect(response.body).to include('2番目の投稿')
          expect(response.body).to include('最新の投稿')
        end

        it '新しい順に表示される' do
          get hare_entries_path
          # 最新の投稿が最初に出現することを確認
          body = response.body
          index_latest = body.index('最新の投稿')
          index_second = body.index('2番目の投稿')
          index_first = body.index('最初の投稿')
          expect(index_latest).to be < index_second
          expect(index_second).to be < index_first
        end

        it '個別投稿への詳細リンクが存在する' do
          get hare_entries_path
          # /hare_entries/数字 のパターンが存在することを確認
          expect(response.body).to match(%r{/hare_entries/\d+})
          expect(response.body).to include(hare_entry_path(entry1))
          expect(response.body).to include(hare_entry_path(entry2))
          expect(response.body).to include(hare_entry_path(entry3))
        end
      end

      context '他ユーザーの投稿' do
        let(:other_user) { User.create!(email: 'other@example.com', password: 'password') }
        let!(:other_entry) { HareEntry.create!(user: other_user, body: '他人の投稿', occurred_on: Date.today, visibility: 'public_post') }
        let!(:my_entry) { HareEntry.create!(user: user, body: '自分の投稿', occurred_on: Date.today, visibility: 'public_post') }

        it '他ユーザーの投稿は表示されない' do
          get hare_entries_path
          expect(response.body).to include('自分の投稿')
          expect(response.body).not_to include('他人の投稿')
        end
      end

      context '投稿がない場合' do
        it '空状態メッセージが表示される' do
          get hare_entries_path
          expect(response.body).to include('まだハレの記録がありません')
        end
      end

      it 'ヘッダーにホームへのリンクが表示される' do
        get hare_entries_path
        expect(response.body).to include('ホーム')
        expect(response.body).to match(%r{<a[^>]*href="#{Regexp.escape(root_path)}"[^>]*>ホーム</a>})
      end

      context '今月のポイント表示' do
        let!(:hare_entry) { HareEntry.create!(user: user, body: 'テスト投稿', occurred_on: Time.zone.today, visibility: 'private_post') }
        let!(:point_rule) { create(:point_rule, key: 'has_tag', points: 1, is_active: true) }
        let!(:point_transaction) do
          create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                     points: 15, awarded_on: Time.zone.today)
        end

        it '今月の合計ポイントが設定される' do
          get hare_entries_path
          expect(assigns(:monthly_points)).to eq 15
        end

        context '複数のポイントが存在する場合' do
          let!(:point_transaction2) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 25, awarded_on: Time.zone.today.end_of_month)
          end

          it '合計が設定される' do
            get hare_entries_path
            expect(assigns(:monthly_points)).to eq 40
          end
        end

        context '先月のポイントがある場合' do
          let!(:last_month_transaction) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 200, awarded_on: 1.month.ago)
          end

          it '今月分のみ設定される' do
            get hare_entries_path
            expect(assigns(:monthly_points)).to eq 15
          end
        end
      end

      context 'レベル表示' do
        let!(:hare_entry) { HareEntry.create!(user: user, body: 'テスト投稿', occurred_on: Time.zone.today, visibility: 'private_post') }
        let!(:point_rule) { create(:point_rule, key: 'has_tag', points: 1, is_active: true) }

        context 'ポイントが0ptの場合' do
          it 'Lv.0が設定される' do
            get hare_entries_path
            expect(assigns(:level)).to eq 0
          end
        end

        context 'ポイントが1ptの場合' do
          let!(:point_transaction) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 1, awarded_on: Time.zone.today)
          end

          it 'Lv.1が設定される（境界値：初投稿でレベルアップ）' do
            get hare_entries_path
            expect(assigns(:level)).to eq 1
          end
        end

        context 'ポイントが10ptの場合' do
          let!(:point_transaction) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 10, awarded_on: Time.zone.today)
          end

          it 'Lv.1が設定される（境界値）' do
            get hare_entries_path
            expect(assigns(:level)).to eq 1
          end
        end

        context 'ポイントが11ptの場合' do
          let!(:point_transaction) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 11, awarded_on: Time.zone.today)
          end

          it 'Lv.2が設定される（境界値）' do
            get hare_entries_path
            expect(assigns(:level)).to eq 2
          end
        end

        context '累計ポイントから算出される' do
          let!(:point_transaction1) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 10, awarded_on: Time.zone.today)
          end
          let!(:point_transaction2) do
            create(:point_transaction, user: user, hare_entry: hare_entry, point_rule: point_rule,
                                       points: 12, awarded_on: 1.month.ago)
          end

          it '全期間の合計（22pt）からLv.3が算出される' do
            get hare_entries_path
            expect(assigns(:level)).to eq 3
          end
        end
      end
    end
  end

  describe "POST /hare_entries" do
    context '未ログイン時' do
      it 'ログイン画面にリダイレクトされる' do
        post hare_entries_path, params: { hare_entry: { body: 'テスト', occurred_on: Date.today } }
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'HareEntryが作成されない' do
        expect {
          post hare_entries_path, params: { hare_entry: { body: 'テスト', occurred_on: Date.today } }
        }.not_to change(HareEntry, :count)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      context '有効なパラメータの場合' do
        let(:valid_params) do
          { hare_entry: { body: 'テストの内容', occurred_on: Date.today, visibility: 'public_post' } }
        end

        before do
          PointRule.destroy_all
        end

        let!(:point_rule) do
          create(:point_rule, key: 'basic_post', label: '基本投稿', points: 1, priority: 1, is_active: true)
        end

        it 'HareEntryが作成される' do
          expect {
            post hare_entries_path, params: valid_params
          }.to change(HareEntry, :count).by(1)
        end

        it '作成された投稿の詳細画面にリダイレクトされる' do
          post hare_entries_path, params: valid_params
          expect(response).to redirect_to(hare_entry_path(HareEntry.last))
        end

        it '成功メッセージが表示される' do
          post hare_entries_path, params: valid_params
          expect(flash[:notice]).to eq('ハレの記録を作成しました')
        end

        it '作成されたHareEntryはログインユーザーに紐づく' do
          post hare_entries_path, params: valid_params
          expect(HareEntry.last.user).to eq(user)
        end

        it 'PointTransactionが作成される' do
          expect {
            post hare_entries_path, params: valid_params
          }.to change(PointTransaction, :count).by(1)
        end

        it 'awarded_pointsが更新される' do
          post hare_entries_path, params: valid_params
          expect(HareEntry.last.awarded_points).to eq(1)
        end
      end

      context 'タグ付きパラメータの場合' do
        let!(:tag1) { create(:hare_tag, key: 'tag1', label: 'タグ1') }
        let!(:tag2) { create(:hare_tag, key: 'tag2', label: 'タグ2') }
        let!(:tag3) { create(:hare_tag, key: 'tag3', label: 'タグ3') }
        let(:params_with_tags) do
          { hare_entry: { body: 'タグ付き投稿', occurred_on: Date.today, visibility: 'private_post', hare_tag_ids: [ tag1.id, tag3.id ] } }
        end

        it 'HareEntryが作成される' do
          expect {
            post hare_entries_path, params: params_with_tags
          }.to change(HareEntry, :count).by(1)
        end

        it '中間テーブルのレコードが作成される' do
          expect {
            post hare_entries_path, params: params_with_tags
          }.to change(HareEntryTag, :count).by(2)
        end

        it '投稿に指定したタグが紐づく' do
          post hare_entries_path, params: params_with_tags
          entry = HareEntry.last
          expect(entry.hare_tags).to contain_exactly(tag1, tag3)
        end
      end

      context 'タグ未選択の場合' do
        let(:params_without_tags) do
          { hare_entry: { body: 'タグなし投稿', occurred_on: Date.today, visibility: 'private_post' } }
        end

        it 'HareEntryが作成される' do
          expect {
            post hare_entries_path, params: params_without_tags
          }.to change(HareEntry, :count).by(1)
        end

        it '中間テーブルのレコードが作成されない' do
          expect {
            post hare_entries_path, params: params_without_tags
          }.not_to change(HareEntryTag, :count)
        end
      end

      context '空のhare_tag_idsの場合' do
        let(:params_with_empty_tag_ids) do
          { hare_entry: { body: '空タグ配列', occurred_on: Date.today, visibility: 'private_post', hare_tag_ids: [] } }
        end

        it 'HareEntryが作成される' do
          expect {
            post hare_entries_path, params: params_with_empty_tag_ids
          }.to change(HareEntry, :count).by(1)
        end

        it '中間テーブルのレコードが作成されない' do
          expect {
            post hare_entries_path, params: params_with_empty_tag_ids
          }.not_to change(HareEntryTag, :count)
        end
      end

      context '非アクティブなタグIDを含む場合' do
        let!(:active_tag) { create(:hare_tag, key: 'active', label: 'アクティブ', is_active: true) }
        let!(:inactive_tag) { create(:hare_tag, key: 'inactive', label: '非アクティブ', is_active: false) }
        let(:params_with_inactive_tag) do
          { hare_entry: { body: '不正タグ投稿', occurred_on: Date.today, visibility: 'private_post', hare_tag_ids: [ active_tag.id, inactive_tag.id ] } }
        end

        it 'HareEntryが作成されない' do
          expect {
            post hare_entries_path, params: params_with_inactive_tag
          }.not_to change(HareEntry, :count)
        end

        it 'エラーメッセージが表示される' do
          post hare_entries_path, params: params_with_inactive_tag
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_params) do
          { hare_entry: { body: '', occurred_on: Date.today } }
        end

        it 'HareEntryが作成されない' do
          expect {
            post hare_entries_path, params: invalid_params
          }.not_to change(HareEntry, :count)
        end

        it 'newテンプレートが再表示される' do
          post hare_entries_path, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('ハレの記録を作成')
        end
      end
    end
  end

  describe "GET /hare_entries/:id/edit" do
    context '未ログイン時' do
      let!(:entry) { HareEntry.create!(user: user, body: 'テスト投稿', occurred_on: Date.today, visibility: 'private_post') }

      it 'ログイン画面にリダイレクトされる' do
        get edit_hare_entry_path(entry)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      context '自分の投稿の場合' do
        let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'public_post') }

        it '正常にアクセスできる' do
          get edit_hare_entry_path(entry)
          expect(response).to have_http_status(:success)
        end

        it '編集フォームが表示される' do
          get edit_hare_entry_path(entry)
          expect(response.body).to include('ハレの記録を編集')
        end

        it '既存の内容が表示される' do
          get edit_hare_entry_path(entry)
          expect(response.body).to include('元の内容')
        end

        it 'ヘッダーにホームへのリンクが表示される' do
          get edit_hare_entry_path(entry)
          expect(response.body).to include('ホーム')
          expect(response.body).to match(%r{<a[^>]*href="#{Regexp.escape(root_path)}"[^>]*>ホーム</a>})
        end
      end

      context 'タグが存在する場合' do
        let!(:tag1) { create(:hare_tag, key: 'tag1', label: 'タグ1', is_active: true, position: 1) }
        let!(:tag2) { create(:hare_tag, key: 'tag2', label: 'タグ2', is_active: true, position: 2) }
        let!(:inactive_tag) { create(:hare_tag, key: 'inactive', label: '非アクティブ', is_active: false, position: 3) }
        let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'public_post', hare_tag_ids: [ tag1.id ]) }

        it 'アクティブなタグがチェックボックスとして表示される' do
          get edit_hare_entry_path(entry)
          expect(response.body).to include('タグ1')
          expect(response.body).to include('タグ2')
        end

        it '非アクティブなタグは表示されない' do
          get edit_hare_entry_path(entry)
          expect(response.body).not_to include('非アクティブ')
        end

        it '現在紐付いているタグが選択済みとして表示される' do
          get edit_hare_entry_path(entry)
          # タグ1が選択されている（checked属性を持つ）
          expect(response.body).to match(/checked="checked"[^>]*>.*タグ1/m)
        end
      end

      context '他ユーザーの投稿の場合' do
        let(:other_user) { User.create!(email: 'other@example.com', password: 'password') }
        let!(:other_entry) { HareEntry.create!(user: other_user, body: '他人の投稿', occurred_on: Date.today, visibility: 'public_post') }

        it '404エラーになる' do
          get edit_hare_entry_path(other_entry)
          expect(response).to have_http_status(:not_found)
        end
      end

      context '存在しないIDの場合' do
        it '404エラーになる' do
          get edit_hare_entry_path(id: 99999)
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe "PATCH /hare_entries/:id" do
    context '未ログイン時' do
      let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'private_post') }

      it 'ログイン画面にリダイレクトされる' do
        patch hare_entry_path(entry), params: { hare_entry: { body: '更新内容' } }
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'HareEntryが更新されない' do
        patch hare_entry_path(entry), params: { hare_entry: { body: '更新内容' } }
        expect(entry.reload.body).to eq('元の内容')
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      context '有効なパラメータの場合' do
        let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'private_post') }
        let(:valid_params) do
          { hare_entry: { body: '更新後の内容', visibility: 'public_post' } }
        end

        it 'HareEntryが更新される' do
          patch hare_entry_path(entry), params: valid_params
          expect(entry.reload.body).to eq('更新後の内容')
          expect(entry.reload.visibility).to eq('public_post')
        end

        it '詳細画面にリダイレクトされる' do
          patch hare_entry_path(entry), params: valid_params
          expect(response).to redirect_to(hare_entry_path(entry))
        end

        it '成功メッセージが表示される' do
          patch hare_entry_path(entry), params: valid_params
          expect(flash[:notice]).to eq('ハレの記録を更新しました')
        end
      end

      context '無効なパラメータの場合' do
        let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'private_post') }
        let(:invalid_params) do
          { hare_entry: { body: '' } }
        end

        it 'HareEntryが更新されない' do
          patch hare_entry_path(entry), params: invalid_params
          expect(entry.reload.body).to eq('元の内容')
        end

        it 'editテンプレートが再表示される' do
          patch hare_entry_path(entry), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('ハレの記録を編集')
        end
      end

      context 'bodyが281文字の場合' do
        let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'private_post') }
        let(:too_long_body) { 'あ' * 281 }

        it 'HareEntryが更新されない' do
          patch hare_entry_path(entry), params: { hare_entry: { body: too_long_body } }
          expect(entry.reload.body).to eq('元の内容')
        end
      end

      context 'タグを更新する場合' do
        let!(:tag1) { create(:hare_tag, key: 'tag1', label: 'タグ1', is_active: true) }
        let!(:tag2) { create(:hare_tag, key: 'tag2', label: 'タグ2', is_active: true) }
        let!(:tag3) { create(:hare_tag, key: 'tag3', label: 'タグ3', is_active: true) }
        let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'private_post', hare_tag_ids: [ tag1.id ]) }

        it 'タグが差し替わる' do
          expect(entry.hare_tags).to contain_exactly(tag1)
          patch hare_entry_path(entry), params: { hare_entry: { body: '元の内容', hare_tag_ids: [ tag2.id, tag3.id ] } }
          expect(entry.reload.hare_tags).to contain_exactly(tag2, tag3)
        end

        it '中間テーブルのレコード数が正しい' do
          expect(entry.hare_entry_tags.count).to eq(1)
          patch hare_entry_path(entry), params: { hare_entry: { body: '元の内容', hare_tag_ids: [ tag2.id, tag3.id ] } }
          expect(entry.reload.hare_entry_tags.count).to eq(2)
        end
      end

      context 'タグを全て外す場合' do
        let!(:tag1) { create(:hare_tag, key: 'tag1', label: 'タグ1', is_active: true) }
        let!(:tag2) { create(:hare_tag, key: 'tag2', label: 'タグ2', is_active: true) }
        let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'private_post', hare_tag_ids: [ tag1.id, tag2.id ]) }

        it 'タグが全て外れる' do
          expect(entry.hare_tags).to contain_exactly(tag1, tag2)
          patch hare_entry_path(entry), params: { hare_entry: { body: '元の内容', hare_tag_ids: [] } }
          expect(entry.reload.hare_tags).to be_empty
        end

        it '中間テーブルのレコードが0件になる' do
          expect(entry.hare_entry_tags.count).to eq(2)
          patch hare_entry_path(entry), params: { hare_entry: { body: '元の内容', hare_tag_ids: [] } }
          expect(entry.reload.hare_entry_tags.count).to eq(0)
        end
      end

      context 'ポイント再計算の統合テスト' do
        before do
          # テストデータを完全にクリア
          PointTransaction.destroy_all
          PointRule.destroy_all

          # テスト用のルール（1つのみ）
          create(:point_rule, key: 'post_base', label: 'ハレ投稿', points: 1, priority: 1, is_active: true)
        end

        context 'タグを追加した場合' do
          let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'private_post') }
          let!(:tag) { create(:hare_tag) }

          before do
            # 初回作成時のポイント付与（タグなし: 1pt）
            PointAwardService.call(entry)
          end

          it 'ポイントが再計算される' do
            expect(entry.reload.awarded_points).to eq(1)

            patch hare_entry_path(entry), params: { hare_entry: { body: '元の内容', hare_tag_ids: [ tag.id ] } }

            # post_base ルールのみなので1ptのまま
            expect(entry.reload.awarded_points).to eq(1)
            expect(entry.point_transactions.count).to eq(1)
          end

          it 'point_transactionsが再作成される' do
            initial_count = entry.point_transactions.count

            patch hare_entry_path(entry), params: { hare_entry: { body: '元の内容', hare_tag_ids: [ tag.id ] } }

            # 削除→再作成されるが、件数は同じ
            expect(entry.reload.point_transactions.count).to eq(initial_count)
          end
        end

        context 'タグを削除した場合' do
          let!(:tag) { create(:hare_tag) }
          let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: Date.today, visibility: 'private_post', hare_tag_ids: [ tag.id ]) }

          before do
            # 初回作成時のポイント付与（タグあり: 1pt）
            PointAwardService.call(entry)
          end

          it 'ポイントが再計算される' do
            expect(entry.reload.awarded_points).to eq(1)

            patch hare_entry_path(entry), params: { hare_entry: { body: '元の内容', hare_tag_ids: [] } }

            # post_base ルールのみなので1ptのまま
            expect(entry.reload.awarded_points).to eq(1)
          end
        end

        context 'occurred_onを変更した場合' do
          let(:old_date) { Date.new(2026, 2, 10) }
          let(:new_date) { Date.new(2026, 2, 9) }
          let!(:entry) { HareEntry.create!(user: user, body: '元の内容', occurred_on: old_date, visibility: 'private_post') }

          before do
            # このテスト用にトランザクションをクリア
            user.point_transactions.destroy_all
            PointAwardService.call(entry)
          end

          it '新しい日付でpoint_transactionsが作成される' do
            patch hare_entry_path(entry), params: { hare_entry: { occurred_on: new_date } }

            transactions = entry.reload.point_transactions
            expect(transactions.pluck(:awarded_on).uniq).to eq([ new_date ])
          end

          it '旧日付の履歴が削除され、新日付の履歴が作成される' do
            old_count = user.point_transactions.where(awarded_on: old_date).count
            expect(old_count).to eq(1)

            patch hare_entry_path(entry), params: { hare_entry: { occurred_on: new_date } }

            expect(user.point_transactions.where(awarded_on: old_date).count).to eq(0)
            expect(user.point_transactions.where(awarded_on: new_date).count).to eq(1)
          end
        end
      end

      context '他ユーザーの投稿の場合' do
        let(:other_user) { User.create!(email: 'other@example.com', password: 'password') }
        let!(:other_entry) { HareEntry.create!(user: other_user, body: '他人の投稿', occurred_on: Date.today, visibility: 'public_post') }

        it '404エラーになる' do
          patch hare_entry_path(other_entry), params: { hare_entry: { body: '不正な更新' } }
          expect(response).to have_http_status(:not_found)
        end

        it 'HareEntryが更新されない' do
          patch hare_entry_path(other_entry), params: { hare_entry: { body: '不正な更新' } }
          expect(other_entry.reload.body).to eq('他人の投稿')
        end
      end
    end
  end

  describe "DELETE /hare_entries/:id" do
    context '未ログイン時' do
      let!(:entry) { HareEntry.create!(user: user, body: 'テスト投稿', occurred_on: Date.today, visibility: 'private_post') }

      it 'ログイン画面にリダイレクトされる' do
        delete hare_entry_path(entry)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'HareEntryが削除されない' do
        expect {
          delete hare_entry_path(entry)
        }.not_to change(HareEntry, :count)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      context '自分の投稿の場合' do
        let!(:entry) { HareEntry.create!(user: user, body: '削除対象の投稿', occurred_on: Date.today, visibility: 'public_post') }

        it 'HareEntryが削除される' do
          expect {
            delete hare_entry_path(entry)
          }.to change(HareEntry, :count).by(-1)
        end

        it '一覧画面にリダイレクトされる' do
          delete hare_entry_path(entry)
          expect(response).to redirect_to(hare_entries_path)
        end

        it '成功メッセージが表示される' do
          delete hare_entry_path(entry)
          expect(flash[:notice]).to eq('ハレの記録を削除しました')
        end
      end

      context '他ユーザーの投稿の場合' do
        let(:other_user) { User.create!(email: 'other@example.com', password: 'password') }
        let!(:other_entry) { HareEntry.create!(user: other_user, body: '他人の投稿', occurred_on: Date.today, visibility: 'public_post') }

        it '404エラーになる' do
          delete hare_entry_path(other_entry)
          expect(response).to have_http_status(:not_found)
        end

        it 'HareEntryが削除されない' do
          expect {
            delete hare_entry_path(other_entry)
          }.not_to change(HareEntry, :count)
        end
      end

      context '存在しないIDの場合' do
        it '404エラーになる' do
          delete hare_entry_path(id: 99999)
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
