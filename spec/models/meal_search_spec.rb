require 'rails_helper'

RSpec.describe MealSearch, type: :model do
  describe 'アソシエーション' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:user) }
  end

  describe 'serialize' do
    let(:user) { create(:user) }
    let(:meal_search) { described_class.new(user: user, genre_id: 1) }

    it 'presented_candidate_names に配列を保存できる' do
      names = [ '唐揚げ', 'カレー', '餃子' ]
      meal_search.presented_candidate_names = names
      meal_search.save!

      # データベースから再読み込み
      saved_search = described_class.find(meal_search.id)
      expect(saved_search.presented_candidate_names).to eq(names)
    end

    it 'presented_candidate_names に空配列を保存できる' do
      meal_search.presented_candidate_names = []
      meal_search.save!

      saved_search = described_class.find(meal_search.id)
      expect(saved_search.presented_candidate_names).to eq([])
    end

    it 'presented_candidate_names が nil の場合も保存できる' do
      meal_search.presented_candidate_names = nil
      meal_search.save!

      saved_search = described_class.find(meal_search.id)
      expect(saved_search.presented_candidate_names).to be_nil
    end
  end

  describe 'enum' do
    describe 'meal_mode' do
      it { is_expected.to define_enum_for(:meal_mode).with_values(ke: 0, hare: 1) }
    end

    describe 'cook_context' do
      it { is_expected.to define_enum_for(:cook_context).with_values(self_cook: 0, eat_out: 1, ready_made: 2) }
    end
  end
end
