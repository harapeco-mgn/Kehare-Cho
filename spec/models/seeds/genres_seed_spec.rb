require 'rails_helper'
require_relative '../../../db/seeds/genres'

RSpec.describe Seeds::Genres do
  describe '.call' do
    context '空のデータベースから実行した場合' do
      before do
        Genre.destroy_all
      end

      it '8件のジャンルを作成すること' do
        expect { described_class.call }.to change(Genre, :count).from(0).to(8)
      end

      it '作成された全てのジャンルが有効であること' do
        described_class.call
        expect(Genre.all).to all(have_attributes(is_active: true))
      end

      it '作成された全てのジャンルに position が設定されていること' do
        described_class.call
        expect(Genre.all).to all(have_attributes(position: be_present))
      end

      it '期待される key が全て作成されること' do
        described_class.call
        expected_keys = %w[
          japanese
          western
          chinese
          noodle
          rice_bowl
          soup
          salad
          snack
        ]
        expect(Genre.pluck(:key)).to match_array(expected_keys)
      end
    end

    context '冪等性の確認' do
      before do
        Genre.destroy_all
      end

      it '2回実行してもレコード数が変わらないこと' do
        described_class.call
        expect { described_class.call }.not_to change(Genre, :count)
      end

      it 'label を手動変更した後に実行しても上書きされないこと' do
        described_class.call
        genre = Genre.find_by!(key: 'japanese')
        genre.update!(label: '日本料理')

        described_class.call
        genre.reload
        expect(genre.label).to eq('日本料理')
      end
    end
  end
end
