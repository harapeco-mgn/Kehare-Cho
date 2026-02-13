require 'rails_helper'

RSpec.describe PointAwardService, type: :service do
  let(:user) { create(:user) }
  let(:hare_entry) { create(:hare_entry, user: user, occurred_on: Date.today) }

  # テスト用のポイントルールを作成（既存のルールを削除してからテスト用を作成）
  before do
    PointRule.destroy_all
  end

  let!(:basic_rule) do
    create(:point_rule, key: 'basic_post', label: '基本投稿', points: 1, priority: 1, is_active: true)
  end

  let!(:bonus_rule) do
    create(:point_rule, key: 'bonus', label: 'ボーナス', points: 2, priority: 2, is_active: true)
  end

  describe '.call' do
    context 'ルールに一致する投稿の場合' do
      it 'point_transactions が作成される' do
        expect {
          described_class.call(hare_entry)
        }.to change(PointTransaction, :count).by(2)
      end

      it '正しいポイント数が付与される' do
        described_class.call(hare_entry)

        transactions = hare_entry.point_transactions.order(:created_at)
        expect(transactions[0].points).to eq(1)  # basic_rule
        expect(transactions[1].points).to eq(2)  # bonus_rule
      end

      it 'awarded_points が更新される' do
        described_class.call(hare_entry)

        expect(hare_entry.reload.awarded_points).to eq(3)
      end

      it '付与したポイント数を返す' do
        result = described_class.call(hare_entry)

        expect(result).to eq(3)
      end

      it 'point_transaction に正しい関連が設定される' do
        described_class.call(hare_entry)

        transaction = hare_entry.point_transactions.first
        expect(transaction.user).to eq(user)
        expect(transaction.hare_entry).to eq(hare_entry)
        expect(transaction.point_rule).to eq(basic_rule)
        expect(transaction.awarded_on).to eq(Date.today)
      end
    end

    context '日次上限に達している場合' do
      before do
        # 既に3pt付与済み
        create(:point_transaction,
               user: user,
               hare_entry: create(:hare_entry, user: user, occurred_on: Date.today),
               point_rule: basic_rule,
               awarded_on: Date.today,
               points: 3)
      end

      it 'point_transactions が作成されない' do
        expect {
          described_class.call(hare_entry)
        }.not_to change(PointTransaction, :count)
      end

      it '0を返す' do
        result = described_class.call(hare_entry)

        expect(result).to eq(0)
      end

      it 'awarded_points が0になる' do
        described_class.call(hare_entry)

        expect(hare_entry.reload.awarded_points).to eq(0)
      end
    end

    context '日次上限の残りが一部の場合' do
      before do
        # 既に2pt付与済み（残り1pt）
        create(:point_transaction,
               user: user,
               hare_entry: create(:hare_entry, user: user, occurred_on: Date.today),
               point_rule: basic_rule,
               awarded_on: Date.today,
               points: 2)
      end

      it 'basic_ruleのみ適用される' do
        expect {
          described_class.call(hare_entry)
        }.to change(PointTransaction, :count).by(1)

        transaction = hare_entry.point_transactions.first
        expect(transaction.point_rule).to eq(basic_rule)
        expect(transaction.points).to eq(1)
      end

      it 'awarded_points が残り分だけ付与される' do
        described_class.call(hare_entry)

        expect(hare_entry.reload.awarded_points).to eq(1)
      end

      it '付与したポイント数を返す' do
        result = described_class.call(hare_entry)

        expect(result).to eq(1)
      end
    end

    context '有効でないルールがある場合' do
      let!(:inactive_rule) do
        create(:point_rule,
               key: 'inactive',
               label: '無効ルール',
               points: 5,
               priority: 0,
               is_active: false)
      end

      it '有効なルールのみ適用される' do
        described_class.call(hare_entry)

        rule_keys = hare_entry.point_transactions.map { |t| t.point_rule.key }
        expect(rule_keys).to contain_exactly('basic_post', 'bonus')
        expect(rule_keys).not_to include('inactive')
      end
    end

    context '別の日の投稿の場合' do
      it '別の日の上限は影響しない' do
        # 時刻を固定して日付の変更による影響を排除
        travel_to Time.zone.local(2026, 2, 14, 12, 0, 0) do
          # 今日（2/14）の投稿を作成
          today_entry = create(:hare_entry, user: user, occurred_on: Date.new(2026, 2, 14))

          # 今日（2/14）に3pt付与済み
          create(:point_transaction,
                 user: user,
                 hare_entry: today_entry,
                 point_rule: basic_rule,
                 awarded_on: Date.new(2026, 2, 14),
                 points: 3)

          # 昨日（2/13）の投稿を作成
          yesterday_entry = create(:hare_entry, user: user, occurred_on: Date.new(2026, 2, 13))

          # 昨日の投稿にポイント付与
          result = described_class.call(yesterday_entry)

          # 昨日の分は3pt付与される（今日の上限とは別）
          expect(result).to eq(3)
        end
      end
    end

    context 'トランザクションのテスト' do
      before do
        # update! が失敗するように設定
        allow(hare_entry).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)
      end

      it '例外が発生した場合、point_transactions もロールバックされる' do
        expect {
          begin
            described_class.call(hare_entry)
          rescue ActiveRecord::RecordInvalid
            # 例外を捕捉
          end
        }.not_to change(PointTransaction, :count)
      end
    end
  end
end
