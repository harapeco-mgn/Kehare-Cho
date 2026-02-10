require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:hare_entries).dependent(:destroy) }
    it { is_expected.to have_many(:point_transactions).dependent(:destroy) }
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
end
