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
