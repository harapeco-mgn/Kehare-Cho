require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password', nickname: 'テストユーザー') }

  describe "GET /profile" do
    context '未ログイン時' do
      it 'ログイン画面にリダイレクトされる' do
        get profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      it '正常にアクセスできる' do
        get profile_path
        expect(response).to have_http_status(:success)
      end

      it 'プロフィールページであることが表示される' do
        get profile_path
        expect(response.body).to include('プロフィール')
      end

      it '表示名が表示される' do
        get profile_path
        expect(response.body).to include(user.display_name)
      end

      it 'メールアドレスが表示される' do
        get profile_path
        expect(response.body).to include(user.email)
      end

      it 'レベルが表示される' do
        get profile_path
        expect(response.body).to include("Lv.#{user.level}")
      end

      it '編集ボタンが表示される' do
        get profile_path
        expect(response.body).to include('編集')
      end

      context 'ハレ投稿が存在する場合' do
        let!(:entry1) { HareEntry.create!(user: user, body: '投稿1', occurred_on: Date.today, visibility: 'private_post') }
        let!(:entry2) { HareEntry.create!(user: user, body: '投稿2', occurred_on: Date.yesterday, visibility: 'private_post') }

        it '総ハレ投稿数が表示される' do
          get profile_path
          expect(response.body).to include('2 件')
        end
      end

      context 'ポイント履歴が存在する場合' do
        let(:point_rule) { create(:point_rule) }
        let(:hare_entry) { HareEntry.create!(user: user, body: 'ポイント用投稿', occurred_on: Date.today, visibility: 'private_post') }

        before do
          PointTransaction.create!(user: user, hare_entry: hare_entry, point_rule: point_rule, awarded_on: Date.current, points: 100)
          PointTransaction.create!(user: user, hare_entry: hare_entry, point_rule: point_rule, awarded_on: Date.current, points: 50)
        end

        it '累計ポイントが表示される' do
          get profile_path
          expect(response.body).to include('150 pt')
        end
      end

      it '登録日が表示される' do
        get profile_path
        expect(response.body).to include(I18n.l(user.created_at.to_date, format: :long))
      end
    end
  end

  describe "GET /profile/edit" do
    context '未ログイン時' do
      it 'ログイン画面にリダイレクトされる' do
        get edit_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      it '正常にアクセスできる' do
        get edit_profile_path
        expect(response).to have_http_status(:success)
      end

      it 'プロフィール編集ページであることが表示される' do
        get edit_profile_path
        expect(response.body).to include('プロフィール編集')
      end

      it 'ニックネーム入力フォームが表示される' do
        get edit_profile_path
        expect(response.body).to include('ニックネーム')
      end

      it 'メールアドレス・パスワード変更への導線が表示される' do
        get edit_profile_path
        expect(response.body).to include('メールアドレス・パスワードの変更')
        expect(response.body).to include(edit_user_registration_path)
      end

      it '更新ボタンが表示される' do
        get edit_profile_path
        expect(response.body).to include('更新')
      end

      it 'キャンセルボタンが表示される' do
        get edit_profile_path
        expect(response.body).to include('キャンセル')
      end
    end
  end

  describe "PATCH /profile" do
    context '未ログイン時' do
      it 'ログイン画面にリダイレクトされる' do
        patch profile_path, params: { user: { nickname: '新しいニックネーム' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'ログイン時' do
      before { sign_in user }

      context '正常なパラメータの場合' do
        it 'ニックネームが更新される' do
          expect do
            patch profile_path, params: { user: { nickname: '新しいニックネーム' } }
          end.to change { user.reload.nickname }.from('テストユーザー').to('新しいニックネーム')
        end

        it 'プロフィール画面にリダイレクトされる' do
          patch profile_path, params: { user: { nickname: '新しいニックネーム' } }
          expect(response).to redirect_to(profile_path)
        end

        it 'フラッシュメッセージが表示される' do
          patch profile_path, params: { user: { nickname: '新しいニックネーム' } }
          follow_redirect!
          expect(response.body).to include('プロフィールを更新しました')
        end
      end

      context 'ニックネームを空にする場合' do
        it 'ニックネームが空文字列に更新される' do
          expect do
            patch profile_path, params: { user: { nickname: '' } }
          end.to change { user.reload.nickname }.from('テストユーザー').to('')
        end
      end

      context '異常なパラメータの場合（21文字以上）' do
        it 'ニックネームが更新されない' do
          expect do
            patch profile_path, params: { user: { nickname: 'あ' * 21 } }
          end.not_to change { user.reload.nickname }
        end

        it '編集画面が再表示される' do
          patch profile_path, params: { user: { nickname: 'あ' * 21 } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'エラーメッセージが表示される' do
          patch profile_path, params: { user: { nickname: 'あ' * 21 } }
          expect(response.body).to include('入力内容にエラーがあります')
        end
      end

      context '既に使用されているニックネームの場合' do
        let!(:other_user) { User.create!(email: 'other@example.com', password: 'password', nickname: '既存ニックネーム') }

        it 'ニックネームが更新されない' do
          expect do
            patch profile_path, params: { user: { nickname: '既存ニックネーム' } }
          end.not_to change { user.reload.nickname }
        end

        it '編集画面が再表示される' do
          patch profile_path, params: { user: { nickname: '既存ニックネーム' } }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'エラーメッセージが表示される' do
          patch profile_path, params: { user: { nickname: '既存ニックネーム' } }
          expect(response.body).to include('入力内容にエラーがあります')
        end
      end
    end
  end
end
