require 'rails_helper'
require_relative '../../../db/seeds/hare_tags'

RSpec.describe Seeds::HareTags do
  describe '.call' do
    context '空のデータベースから実行した場合' do
      before do
        HareTag.destroy_all
      end

      it '10件のハレタグを作成すること' do
        expect { described_class.call }.to change(HareTag, :count).from(0).to(10)
      end

      it '作成された全てのタグが有効であること' do
        described_class.call
        expect(HareTag.all).to all(have_attributes(is_active: true))
      end

      it '作成された全てのタグに position が設定されていること' do
        described_class.call
        expect(HareTag.all).to all(have_attributes(position: be_present))
      end

      it '期待される key が全て作成されること' do
        described_class.call
        expected_keys = %w[
          homemade_meal
          seasonal_ingredient
          new_recipe
          colorful_dish
          plating
          local_specialty
          unusual_ingredient
          cooking_tool
          preserved_food
          outdoor_meal
        ]
        expect(HareTag.pluck(:key)).to match_array(expected_keys)
      end
    end

    context '冪等性の確認' do
      before do
        HareTag.destroy_all
      end

      it '2回実行してもレコード数が変わらないこと' do
        described_class.call
        expect { described_class.call }.not_to change(HareTag, :count)
      end

      it 'label を手動変更した後に実行しても上書きされないこと' do
        described_class.call
        tag = HareTag.find_by!(key: 'homemade_meal')
        tag.update!(label: '手料理')

        described_class.call
        tag.reload
        expect(tag.label).to eq('手料理')
      end
    end
  end
end
