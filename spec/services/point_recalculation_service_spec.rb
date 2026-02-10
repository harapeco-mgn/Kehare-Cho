require 'rails_helper'

RSpec.describe PointRecalculationService, type: :service do
  let(:user) { create(:user) }
  let(:hare_entry) { create(:hare_entry, user: user, occurred_on: Date.new(2026, 2, 10)) }

  before do
    # テストデータを完全にクリア
    PointTransaction.destroy_all
    PointRule.destroy_all

    # テスト用のルール（1つのみ）
    create(:point_rule, key: 'post_base', label: 'ハレ投稿', points: 1, priority: 1, is_active: true)
  end

  describe '.call' do
    context '既存のポイント履歴がある状態で再計算する場合' do
      before do
        # 初回作成時のポイント付与（タグなし: 1pt）
        PointAwardService.call(hare_entry)
      end

      it '既存の point_transactions が削除される' do
        expect {
          PointRecalculationService.call(hare_entry)
        }.not_to change { PointTransaction.count }
        # 削除→再作成で件数は変わらない
      end

      it '最新の条件でポイントが再計算される' do
        # タグを追加（ただし post_base ルールのみなのでポイントは変わらない）
        tag = create(:hare_tag)
        hare_entry.hare_tags << tag

        PointRecalculationService.call(hare_entry)

        # post_base (1pt) のみ
        expect(hare_entry.reload.awarded_points).to eq(1)
        expect(hare_entry.point_transactions.count).to eq(1)
      end

      it 'awarded_points が正しく計算される' do
        # 再計算を実行
        PointRecalculationService.call(hare_entry)

        # post_base (1pt) が適用される
        expect(hare_entry.reload.awarded_points).to eq(1)
      end
    end

    context 'occurred_on を変更した場合' do
      let(:old_date) { Date.new(2026, 2, 10) }
      let(:new_date) { Date.new(2026, 2, 9) }

      before do
        # このテスト用にトランザクションをクリア
        user.point_transactions.destroy_all
        hare_entry.update!(occurred_on: old_date)
        PointAwardService.call(hare_entry)
      end

      it '新しい日付で point_transactions が作成される' do
        hare_entry.update!(occurred_on: new_date)
        PointRecalculationService.call(hare_entry)

        transactions = hare_entry.reload.point_transactions
        expect(transactions.pluck(:awarded_on).uniq).to eq([ new_date ])
      end

      it '旧日付の履歴は削除され、新日付の履歴が作成される' do
        old_count = user.point_transactions.where(awarded_on: old_date).count
        expect(old_count).to eq(1)

        hare_entry.update!(occurred_on: new_date)
        PointRecalculationService.call(hare_entry)

        # 旧日付の履歴が減る
        expect(user.point_transactions.where(awarded_on: old_date).count).to eq(0)
        # 新日付の履歴が増える
        expect(user.point_transactions.where(awarded_on: new_date).count).to eq(1)
      end
    end

    context '日次上限を考慮した再計算' do
      let(:occurred_on) { Date.new(2026, 2, 10) }

      before do
        hare_entry.update!(occurred_on: occurred_on)
      end

      it '日次上限内で再計算される' do
        # 別の投稿2つで2pt消費済み
        other_entry1 = create(:hare_entry, user: user, occurred_on: occurred_on)
        PointAwardService.call(other_entry1)
        other_entry2 = create(:hare_entry, user: user, occurred_on: occurred_on)
        PointAwardService.call(other_entry2)

        expect(user.point_transactions.where(awarded_on: occurred_on).sum(:points)).to eq(2)

        # この投稿は残り1ptのみ付与可能
        hare_entry.update!(occurred_on: occurred_on)
        PointRecalculationService.call(hare_entry)

        # post_base (1pt) が付与される（上限3ptまで）
        expect(hare_entry.reload.awarded_points).to eq(1)
        expect(user.point_transactions.where(awarded_on: occurred_on).sum(:points)).to eq(3)
      end

      it '日次上限を超えない' do
        # すでに3pt消費済み
        3.times do
          entry = create(:hare_entry, user: user, occurred_on: occurred_on)
          PointAwardService.call(entry)
        end

        expect(user.point_transactions.where(awarded_on: occurred_on).sum(:points)).to eq(3)

        # この投稿を再計算しても上限を超えない
        PointRecalculationService.call(hare_entry)

        expect(user.point_transactions.where(awarded_on: occurred_on).sum(:points)).to eq(3)
      end
    end

    context 'トランザクションのロールバック' do
      it 'PointAwardService でエラーが発生した場合、削除もロールバックされる' do
        PointAwardService.call(hare_entry)
        initial_count = hare_entry.point_transactions.count

        # PointAwardService でエラーを発生させる
        allow(PointAwardService).to receive(:call).and_raise(StandardError, 'テストエラー')

        expect {
          PointRecalculationService.call(hare_entry)
        }.to raise_error(StandardError, 'テストエラー')

        # トランザクションがロールバックされるため、削除も取り消される
        expect(hare_entry.point_transactions.count).to eq(initial_count)
      end
    end

    context 'タグの追加・削除による再計算' do
      let(:tag1) { create(:hare_tag, key: 'tag1') }
      let(:tag2) { create(:hare_tag, key: 'tag2') }

      it 'タグを追加しても再計算が正しく動作する' do
        PointAwardService.call(hare_entry)
        expect(hare_entry.reload.awarded_points).to eq(1)

        hare_entry.hare_tags << tag1
        PointRecalculationService.call(hare_entry)

        # post_base ルールのみなのでポイントは1ptのまま
        expect(hare_entry.reload.awarded_points).to eq(1)
        expect(hare_entry.point_transactions.count).to eq(1)
      end

      it 'タグを削除しても再計算が正しく動作する' do
        hare_entry.hare_tags << tag1
        PointAwardService.call(hare_entry)
        expect(hare_entry.reload.awarded_points).to eq(1)

        hare_entry.hare_tags.clear
        PointRecalculationService.call(hare_entry)

        # post_base ルールのみなのでポイントは1ptのまま
        expect(hare_entry.reload.awarded_points).to eq(1)
        expect(hare_entry.point_transactions.count).to eq(1)
      end
    end
  end
end
