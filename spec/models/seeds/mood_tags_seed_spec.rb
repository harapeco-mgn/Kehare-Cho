require 'rails_helper'
require_relative '../../../db/seeds/mood_tags'

RSpec.describe Seeds::MoodTags do
  describe '.call' do
    context '空のデータベースから実行した場合' do
      before do
        MoodTag.destroy_all
      end

      it '6件の気分タグを作成すること' do
        expect { described_class.call }.to change(MoodTag, :count).from(0).to(6)
      end

      it '作成された全ての気分タグが有効であること' do
        described_class.call
        expect(MoodTag.all).to all(have_attributes(is_active: true))
      end

      it '作成された全ての気分タグに position が設定されていること' do
        described_class.call
        expect(MoodTag.all).to all(have_attributes(position: be_present))
      end

      it '期待される key が全て作成されること' do
        described_class.call
        expected_keys = %w[
          light
          rich
          warm
          hearty
          healthy
          easy
        ]
        expect(MoodTag.pluck(:key)).to match_array(expected_keys)
      end
    end

    context '冪等性の確認' do
      before do
        MoodTag.destroy_all
      end

      it '2回実行してもレコード数が変わらないこと' do
        described_class.call
        expect { described_class.call }.not_to change(MoodTag, :count)
      end

      it 'label を手動変更した後に実行しても上書きされないこと' do
        described_class.call
        mood = MoodTag.find_by!(key: 'light')
        mood.update!(label: 'さっぱり系')

        described_class.call
        mood.reload
        expect(mood.label).to eq('さっぱり系')
      end
    end
  end
end
