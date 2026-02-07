require 'rails_helper'
require_relative '../../../db/seeds/hare_tags'
require_relative '../../../db/seeds/genres'
require_relative '../../../db/seeds/mood_tags'
require_relative '../../../db/seeds/meal_candidates'
require_relative '../../../db/seeds/point_rules'
require_relative '../../../db/seeds/all'

RSpec.describe Seeds::All do
  describe '.call' do
    context '空のデータベースから実行した場合' do
      before do
        HareTag.destroy_all
        Genre.destroy_all
        MoodTag.destroy_all
        MealCandidate.destroy_all
        PointRule.destroy_all
      end

      it '全てのマスタデータが作成されること' do
        expect { described_class.call }.to change {
          [ HareTag.count, Genre.count, MoodTag.count, MealCandidate.count, PointRule.count ]
        }
      end

      it 'HareTagが作成されること' do
        expect { described_class.call }.to change(HareTag, :count).from(0)
      end

      it 'Genreが作成されること' do
        expect { described_class.call }.to change(Genre, :count).from(0)
      end

      it 'MoodTagが作成されること' do
        expect { described_class.call }.to change(MoodTag, :count).from(0)
      end

      it 'MealCandidateが作成されること' do
        expect { described_class.call }.to change(MealCandidate, :count).from(0)
      end

      it 'PointRuleが作成されること' do
        expect { described_class.call }.to change(PointRule, :count).from(0)
      end
    end

    context '冪等性の確認' do
      before do
        HareTag.destroy_all
        Genre.destroy_all
        MoodTag.destroy_all
        MealCandidate.destroy_all
        PointRule.destroy_all
        described_class.call # 1回目実行
      end

      it '2回実行してもレコード数が変わらないこと' do
        hare_tag_count = HareTag.count
        genre_count = Genre.count
        mood_tag_count = MoodTag.count
        meal_candidate_count = MealCandidate.count
        point_rule_count = PointRule.count

        described_class.call # 2回目実行

        expect(HareTag.count).to eq(hare_tag_count)
        expect(Genre.count).to eq(genre_count)
        expect(MoodTag.count).to eq(mood_tag_count)
        expect(MealCandidate.count).to eq(meal_candidate_count)
        expect(PointRule.count).to eq(point_rule_count)
      end

      it '3回実行してもエラーにならないこと' do
        expect { described_class.call }.not_to raise_error
        expect { described_class.call }.not_to raise_error
      end
    end
  end
end
