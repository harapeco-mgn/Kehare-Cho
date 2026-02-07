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
end
