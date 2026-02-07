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

        it 'ホーム画面にリダイレクトされる' do
          post hare_entries_path, params: valid_params
          expect(response).to redirect_to(root_path)
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
end
