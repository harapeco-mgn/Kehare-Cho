require 'rails_helper'
require_relative '../../../db/seeds/point_rules'

RSpec.describe Seeds::PointRules do
  describe '.call' do
    context '空のデータベースから実行した場合' do
      before do
        PointRule.destroy_all
      end

      it '3件のポイントルールを作成すること' do
        expect { described_class.call }.to change(PointRule, :count).from(0).to(3)
      end

      it '付与ルール（post_base, bonus_budget_up）が有効であること' do
        described_class.call
        grant_rules = PointRule.where(key: %w[post_base bonus_budget_up])
        expect(grant_rules).to all(have_attributes(is_active: true))
      end

      it '設定ルール（daily_limit）が無効であること' do
        described_class.call
        config_rule = PointRule.find_by!(key: 'daily_limit')
        expect(config_rule.is_active).to be false
      end

      it '作成された全てのルールに priority が設定されていること' do
        described_class.call
        expect(PointRule.all).to all(have_attributes(priority: be_present))
      end

      it '作成された全てのルールに points が設定されていること' do
        described_class.call
        expect(PointRule.all).to all(have_attributes(points: be_present))
      end

      it '期待される key が全て作成されること' do
        described_class.call
        expected_keys = %w[
          post_base
          bonus_budget_up
          daily_limit
        ]
        expect(PointRule.pluck(:key)).to match_array(expected_keys)
      end

      it 'bonus_budget_up の params に min_price_yen が設定されていること' do
        described_class.call
        rule = PointRule.find_by!(key: 'bonus_budget_up')
        expect(rule.params).to eq({ 'min_price_yen' => 500 })
      end

      it 'daily_limit の points が 3 であること' do
        described_class.call
        rule = PointRule.find_by!(key: 'daily_limit')
        expect(rule.points).to eq(3)
      end
    end

    context '冪等性の確認' do
      before do
        PointRule.destroy_all
      end

      it '2回実行してもレコード数が変わらないこと' do
        described_class.call
        expect { described_class.call }.not_to change(PointRule, :count)
      end

      it 'label を手動変更した後に実行しても上書きされないこと' do
        described_class.call
        rule = PointRule.find_by!(key: 'post_base')
        rule.update!(label: 'カスタム投稿')

        described_class.call
        rule.reload
        expect(rule.label).to eq('カスタム投稿')
      end
    end
  end
end
