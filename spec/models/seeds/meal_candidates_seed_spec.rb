require 'rails_helper'
require_relative '../../../db/seeds/genres'
require_relative '../../../db/seeds/meal_candidates'

RSpec.describe Seeds::MealCandidates do
  describe '.call' do
    before do
      # 前提条件: Genreのseedを先に実行
      Genre.destroy_all
      MealCandidate.destroy_all
      Seeds::Genres.call
    end

    context '空のデータベースから実行した場合' do
      it '候補料理名が作成されること' do
        expect { described_class.call }.to change(MealCandidate, :count).by_at_least(1)
      end

      it '各ジャンルに最低20件の候補が存在すること' do
        described_class.call
        Genre.all.each do |genre|
          expect(genre.meal_candidates.count).to be >= 20
        end
      end

      it '作成された全ての候補が有効であること' do
        described_class.call
        expect(MealCandidate.all).to all(have_attributes(is_active: true))
      end

      it '作成された全ての候補に position が設定されていること' do
        described_class.call
        expect(MealCandidate.all).to all(have_attributes(position: be_present))
      end
    end

    context '冪等性の確認' do
      it '2回実行してもレコード数が変わらないこと' do
        described_class.call
        expect { described_class.call }.not_to change(MealCandidate, :count)
      end

      it 'name を手動変更した後に実行しても上書きされないこと' do
        described_class.call
        candidate = MealCandidate.first
        original_genre = candidate.genre
        candidate.update!(name: '手動変更した料理名')

        described_class.call
        candidate.reload
        expect(candidate.name).to eq('手動変更した料理名')
        expect(candidate.genre).to eq(original_genre)
      end
    end
  end
end
