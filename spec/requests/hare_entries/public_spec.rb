require 'rails_helper'

RSpec.describe "HareEntries::Public", type: :request do
  describe "GET /hare_entries/public" do
    let(:user1) { User.create!(email: 'user1@example.com', password: 'password', nickname: 'ユーザー1') }
    let(:user2) { User.create!(email: 'user2@example.com', password: 'password', nickname: 'ユーザー2') }

    context '未ログイン時' do
      it '正常にアクセスできる' do
        get public_hare_entries_path
        expect(response).to have_http_status(:success)
      end

      it 'みんなのハレタイトルが表示される' do
        get public_hare_entries_path
        expect(response.body).to include('みんなのハレ')
      end
    end

    context 'ログイン時' do
      before { sign_in user1 }

      it '正常にアクセスできる' do
        get public_hare_entries_path
        expect(response).to have_http_status(:success)
      end
    end

    context '公開投稿の表示' do
      let!(:public_entry1) { HareEntry.create!(user: user1, body: '公開投稿1', occurred_on: 2.days.ago, visibility: 'public_post') }
      let!(:public_entry2) { HareEntry.create!(user: user2, body: '公開投稿2', occurred_on: 1.day.ago, visibility: 'public_post') }
      let!(:private_entry) { HareEntry.create!(user: user1, body: '非公開投稿', occurred_on: Date.today, visibility: 'private_post') }

      it '公開投稿のみ表示される' do
        get public_hare_entries_path
        expect(response.body).to include('公開投稿1')
        expect(response.body).to include('公開投稿2')
      end

      it '非公開投稿は表示されない' do
        get public_hare_entries_path
        expect(response.body).not_to include('非公開投稿')
      end

      it 'ユーザー名が表示される' do
        get public_hare_entries_path
        expect(response.body).to include('ユーザー1')
        expect(response.body).to include('ユーザー2')
      end
    end

    context 'ソート順' do
      let!(:old_entry) { HareEntry.create!(user: user1, body: '古い投稿', occurred_on: 3.days.ago, visibility: 'public_post') }
      let!(:middle_entry) { HareEntry.create!(user: user1, body: '中間の投稿', occurred_on: 2.days.ago, visibility: 'public_post') }
      let!(:new_entry) { HareEntry.create!(user: user1, body: '新しい投稿', occurred_on: 1.day.ago, visibility: 'public_post') }

      it '新しい順（occurred_on降順）で表示される' do
        get public_hare_entries_path
        body = response.body
        index_new = body.index('新しい投稿')
        index_middle = body.index('中間の投稿')
        index_old = body.index('古い投稿')
        expect(index_new).to be < index_middle
        expect(index_middle).to be < index_old
      end
    end

    context 'タグの表示' do
      let!(:tag1) { create(:hare_tag, key: 'tag1', label: 'タグ1') }
      let!(:tag2) { create(:hare_tag, key: 'tag2', label: 'タグ2') }
      let!(:entry_with_tags) do
        HareEntry.create!(
          user: user1,
          body: 'タグ付き投稿',
          occurred_on: Date.today,
          visibility: 'public_post',
          hare_tag_ids: [ tag1.id, tag2.id ]
        )
      end

      it 'タグが表示される' do
        get public_hare_entries_path
        expect(response.body).to include('タグ1')
        expect(response.body).to include('タグ2')
      end
    end

    context '写真の表示' do
      let(:entry_with_photo) do
        entry = HareEntry.create!(
          user: user1,
          body: '写真付き投稿',
          occurred_on: Date.today,
          visibility: 'public_post'
        )
        # テスト用の画像をアタッチ
        entry.photo.attach(
          io: StringIO.new('fake image content'),
          filename: 'sample.jpg',
          content_type: 'image/jpeg'
        )
        entry
      end

      before { entry_with_photo }

      it '写真付き投稿が表示される' do
        get public_hare_entries_path
        expect(response.body).to include('写真付き投稿')
      end
    end

    context 'ページネーション' do
      before do
        # 26件の公開投稿を作成（1ページあたり25件）
        26.times do |i|
          HareEntry.create!(
            user: user1,
            body: "公開投稿#{i + 1}",
            occurred_on: Date.today - i.days,
            visibility: 'public_post'
          )
        end
      end

      it '1ページ目には25件が表示される' do
        get public_hare_entries_path(page: 1)
        expect(response).to have_http_status(:success)
        # 最新の投稿（公開投稿1）と最も古い投稿（公開投稿25）が表示されることを確認
        expect(response.body).to include('公開投稿1')
        expect(response.body).to include('公開投稿25')
        # 26番目は表示されない
        expect(response.body).not_to include('公開投稿26')
      end

      it '2ページ目には1件が表示される' do
        get public_hare_entries_path(page: 2)
        expect(response).to have_http_status(:success)
        # 26番目のみ表示される
        expect(response.body).to include('公開投稿26')
        expect(response.body).not_to include('公開投稿25')
      end

      it 'ページネーションリンクが表示される' do
        get public_hare_entries_path(page: 1)
        expect(response.body).to include('href="/hare_entries/public?page=2"')
      end
    end

    context '投稿がない場合' do
      it '空状態メッセージが表示される' do
        get public_hare_entries_path
        expect(response.body).to include('まだ公開されている投稿がありません')
      end
    end
  end
end
