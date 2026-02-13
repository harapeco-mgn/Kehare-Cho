require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:hare_entries).dependent(:destroy) }
    it { is_expected.to have_many(:point_transactions).dependent(:destroy) }
  end

  describe 'validations' do
    describe 'nickname' do
      context 'ニックネームがnilの場合' do
        it 'バリデーションが通る' do
          user = build(:user, nickname: nil)
          expect(user).to be_valid
        end
      end

      context 'ニックネームが空文字列の場合' do
        it 'バリデーションが通る（nilとして扱われる）' do
          user = build(:user, nickname: '')
          expect(user).to be_valid
        end
      end

      context 'ニックネームが20文字の場合' do
        it 'バリデーションが通る（境界値）' do
          user = build(:user, nickname: 'a' * 20)
          expect(user).to be_valid
        end
      end

      context 'ニックネームが21文字の場合' do
        it 'バリデーションエラーになる' do
          user = build(:user, nickname: 'a' * 21)
          expect(user).not_to be_valid
          expect(user.errors[:nickname]).to include('は20文字以内で入力してください')
        end
      end

      context '同じニックネームのユーザーが既に存在する場合' do
        before do
          create(:user, nickname: 'たろう')
        end

        it '大文字小文字を区別せずにバリデーションエラーになる' do
          user = build(:user, nickname: 'たろう')
          expect(user).not_to be_valid
          expect(user.errors[:nickname]).to include('はすでに存在します')
        end

        it '大文字小文字の違いでもバリデーションエラーになる（英字）' do
          create(:user, nickname: 'Taro')
          user = build(:user, nickname: 'taro')
          expect(user).not_to be_valid
        end
      end

      context 'ニックネームが異なる場合' do
        before do
          create(:user, nickname: 'たろう')
        end

        it 'バリデーションが通る' do
          user = build(:user, nickname: 'じろう')
          expect(user).to be_valid
        end
      end
    end
  end

  describe '#display_name' do
    context 'ニックネームが設定されている場合' do
      let(:user) { create(:user, email: 'test@example.com', nickname: 'たろう') }

      it 'ニックネームを返す' do
        expect(user.display_name).to eq 'たろう'
      end
    end

    context 'ニックネームが設定されていない場合' do
      let(:user) { create(:user, email: 'test@example.com', nickname: nil) }

      it 'メールアドレスの@より前の部分を返す' do
        expect(user.display_name).to eq 'test'
      end
    end

    context 'ニックネームが空文字列の場合' do
      let(:user) { create(:user, email: 'user123@example.com', nickname: '') }

      it 'メールアドレスの@より前の部分を返す' do
        expect(user.display_name).to eq 'user123'
      end
    end
  end

  describe '#monthly_points' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context '今月のポイントが存在する場合' do
      before do
        # 今月のポイント
        create(:point_transaction, user: user, points: 10, awarded_on: Time.zone.today)
        create(:point_transaction, user: user, points: 20, awarded_on: Time.zone.today.beginning_of_month)
        create(:point_transaction, user: user, points: 5, awarded_on: Time.zone.today.end_of_month)
      end

      it '今月の合計ポイントを返す' do
        expect(user.monthly_points).to eq 35
      end
    end

    context '先月のポイントが存在する場合' do
      before do
        # 先月のポイント（集計対象外）
        create(:point_transaction, user: user, points: 100, awarded_on: 1.month.ago)
      end

      it '先月のポイントは含まれない' do
        expect(user.monthly_points).to eq 0
      end
    end

    context '他のユーザーのポイントが存在する場合' do
      before do
        # 今月の他ユーザーのポイント（集計対象外）
        create(:point_transaction, user: other_user, points: 50, awarded_on: Time.zone.today)
      end

      it '他のユーザーのポイントは含まれない' do
        expect(user.monthly_points).to eq 0
      end
    end

    context 'ポイントが存在しない場合' do
      it '0を返す' do
        expect(user.monthly_points).to eq 0
      end
    end

    context '月をまたいだポイントが存在する場合' do
      before do
        travel_to Time.zone.local(2026, 2, 15, 12, 0, 0) # 2026年2月15日12時に固定
        # 今月のポイント
        create(:point_transaction, user: user, points: 10, awarded_on: Date.new(2026, 2, 1))
        create(:point_transaction, user: user, points: 20, awarded_on: Date.new(2026, 2, 28))
        # 先月のポイント
        create(:point_transaction, user: user, points: 30, awarded_on: Date.new(2026, 1, 31))
        # 来月のポイント
        create(:point_transaction, user: user, points: 40, awarded_on: Date.new(2026, 3, 1))
      end

      after do
        travel_back
      end

      it '今月分のみ集計される' do
        expect(user.monthly_points).to eq 30
      end
    end
  end

  describe '#level' do
    let(:user) { create(:user) }

    context 'ポイントが0ptのとき' do
      it 'Lv.0を返す' do
        expect(user.level).to eq(0)
      end
    end

    context 'ポイントが1ptのとき' do
      before do
        create(:point_transaction, user: user, points: 1, awarded_on: Time.zone.today)
      end

      it 'Lv.1を返す（初投稿でレベルアップ）' do
        expect(user.level).to eq(1)
      end
    end

    context 'ポイントが10ptのとき' do
      before do
        create(:point_transaction, user: user, points: 10, awarded_on: Time.zone.today)
      end

      it 'Lv.1を返す（境界値）' do
        expect(user.level).to eq(1)
      end
    end

    context 'ポイントが11ptのとき' do
      before do
        create(:point_transaction, user: user, points: 11, awarded_on: Time.zone.today)
      end

      it 'Lv.2を返す（境界値）' do
        expect(user.level).to eq(2)
      end
    end

    context 'ポイントが20ptのとき' do
      before do
        create(:point_transaction, user: user, points: 20, awarded_on: Time.zone.today)
      end

      it 'Lv.2を返す（境界値）' do
        expect(user.level).to eq(2)
      end
    end

    context 'ポイントが21ptのとき' do
      before do
        create(:point_transaction, user: user, points: 21, awarded_on: Time.zone.today)
      end

      it 'Lv.3を返す（境界値）' do
        expect(user.level).to eq(3)
      end
    end

    context 'ポイントが25ptのとき' do
      before do
        create(:point_transaction, user: user, points: 25, awarded_on: Time.zone.today)
      end

      it 'Lv.3を返す' do
        expect(user.level).to eq(3)
      end
    end

    context 'ポイントがマイナス（-10pt）のとき' do
      before do
        create(:point_transaction, user: user, points: -10, awarded_on: Time.zone.today)
      end

      it 'Lv.0を返す（下限）' do
        expect(user.level).to eq(0)
      end
    end

    context '複数のポイントトランザクションが存在する場合' do
      before do
        create(:point_transaction, user: user, points: 5, awarded_on: Time.zone.today)
        create(:point_transaction, user: user, points: 10, awarded_on: 1.day.ago)
        create(:point_transaction, user: user, points: 7, awarded_on: 2.days.ago)
      end

      it '累計ポイント（22pt）から正しくレベル（Lv.3）を算出する' do
        expect(user.level).to eq(3)
      end
    end
  end
end
