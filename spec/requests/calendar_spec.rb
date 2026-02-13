require 'rails_helper'

RSpec.describe 'Calendar', type: :request do
  let(:user) { create(:user) }

  describe 'GET /calendar' do
    context '未ログインの場合' do
      it 'ログイン画面にリダイレクトされる' do
        get calendar_path
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before do
        sign_in user
      end

      context '投稿がない場合' do
        it '200 が返り、カレンダーが表示される' do
          get calendar_path
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('calendar')
        end
      end

      context '今月の投稿がある場合' do
        let!(:hare_entry) do
          create(:hare_entry,
                 user: user,
                 body: 'カレンダーテスト投稿',
                 occurred_on: Date.today)
        end

        it '200 が返り、カレンダーに投稿が表示される' do
          get calendar_path
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('calendar')
          expect(response.body).to include('カレンダーテスト投稿')
          expect(response.body).to include(Date.today.day.to_s)
        end
      end

      context '先月の投稿がある場合（表示月のみ取得の検証）' do
        let!(:last_month_entry) do
          create(:hare_entry,
                 user: user,
                 body: '先月の投稿',
                 occurred_on: 1.month.ago)
        end

        it '今月のカレンダーには先月の投稿が表示されない' do
          get calendar_path
          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include('先月の投稿')
        end
      end

      context '月をパラメータで指定した場合' do
        let!(:next_month_entry) do
          create(:hare_entry,
                 user: user,
                 body: '来月の投稿',
                 occurred_on: 1.month.from_now.beginning_of_month)
        end

        it '指定した月の投稿が表示される' do
          get calendar_path, params: { start_date: 1.month.from_now.beginning_of_month }
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('来月の投稿')
        end
      end

      context '他のユーザーの投稿がある場合' do
        let(:other_user) { create(:user) }
        let!(:other_entry) do
          create(:hare_entry,
                 user: other_user,
                 body: '他人の投稿',
                 occurred_on: Date.today)
        end

        it '他のユーザーの投稿は表示されない' do
          get calendar_path
          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include('他人の投稿')
        end
      end
    end
  end

  describe 'GET /calendar/:date (日別一覧)' do
    let(:target_date) { Date.today }

    context '未ログインの場合' do
      it 'ログイン画面にリダイレクトされる' do
        get "/calendar/#{target_date}"
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン済みの場合' do
      before do
        sign_in user
      end

      context '指定日に投稿がない場合' do
        it '200 が返り、投稿なしメッセージが表示される' do
          get "/calendar/#{target_date}"
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('この日はまだハレがありません')
        end
      end

      context '指定日に投稿がある場合' do
        let!(:entry_on_date) do
          create(:hare_entry,
                 user: user,
                 body: 'テスト投稿',
                 occurred_on: target_date)
        end

        it '200 が返り、その日の投稿が表示される' do
          get "/calendar/#{target_date}"
          expect(response).to have_http_status(:ok)
          expect(response.body).to include('テスト投稿')
          expect(response.body).to include(target_date.strftime('%Y年%-m月%-d日'))
        end
      end

      context '他の日の投稿がある場合' do
        let!(:other_date_entry) do
          create(:hare_entry,
                 user: user,
                 body: '他の日の投稿',
                 occurred_on: target_date + 1.day)
        end

        it 'その日の投稿は表示されない' do
          get "/calendar/#{target_date}"
          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include('他の日の投稿')
        end
      end

      context '他のユーザーの投稿がある場合' do
        let(:other_user) { create(:user) }
        let!(:other_user_entry) do
          create(:hare_entry,
                 user: other_user,
                 body: '他人の投稿',
                 occurred_on: target_date)
        end

        it '他のユーザーの投稿は表示されない' do
          get "/calendar/#{target_date}"
          expect(response).to have_http_status(:ok)
          expect(response.body).not_to include('他人の投稿')
        end
      end
    end
  end

  describe '画面遷移' do
    before do
      sign_in user
    end

    let(:target_date) { Date.today }
    let!(:entry_on_date) do
      create(:hare_entry,
             user: user,
             body: '遷移テスト用投稿',
             occurred_on: target_date)
    end

    it '/home に /calendar へのリンクが存在する' do
      get home_path
      expect(response.body).to include('calendar')
      expect(response.body).to include('カレンダー')
    end

    it '/calendar のヘッダーに /home への導線が存在する' do
      get calendar_path
      expect(response.body).to include('home')
      expect(response.body).to include('ホーム')
    end

    context '/calendar (月表示) からの遷移' do
      it '日付セルに /calendar/:date へのリンクが存在する' do
        get calendar_path
        expect(response.body).to include("/calendar/#{target_date}")
      end
    end

    context '/calendar/:date (日別一覧) からの遷移' do
      it '投稿詳細 (/hare_entries/:id) へのリンクが存在する' do
        get "/calendar/#{target_date}"
        expect(response.body).to include("/hare_entries/#{entry_on_date.id}")
      end

      it '新規投稿 (/hare_entries/new) へのリンクが存在する' do
        get "/calendar/#{target_date}"
        expect(response.body).to include('/hare_entries/new')
        expect(response.body).to include('新規投稿')
      end

      it '月へ戻る (/calendar) へのリンクが存在する' do
        get "/calendar/#{target_date}"
        expect(response.body).to include('calendar')
        expect(response.body).to include('月へ戻る')
      end

      it 'ヘッダーに /home への導線が存在する' do
        get "/calendar/#{target_date}"
        expect(response.body).to include('home')
        expect(response.body).to include('ホーム')
      end
    end
  end
end
