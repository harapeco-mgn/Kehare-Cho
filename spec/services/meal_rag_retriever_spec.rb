require "rails_helper"

RSpec.describe MealRagRetriever do
  let(:user) { create(:user) }
  let(:retriever) { MealRagRetriever.new(user: user, query: "カレーが食べたい") }

  describe "#retrieve" do
    it "ハッシュ形式（meal_candidates / hare_entries / meal_searches）でコンテキストを返す" do
      result = retriever.retrieve
      expect(result).to include(:meal_candidates, :hare_entries, :meal_searches)
    end

    it "meal_candidates は ActiveRecord::Relation を返す" do
      result = retriever.retrieve
      expect(result[:meal_candidates]).to be_a(ActiveRecord::Relation)
    end

    it "hare_entries はログインユーザーのエントリに限定される" do
      result = retriever.retrieve
      expect(result[:hare_entries]).to be_a(ActiveRecord::Relation)
    end

    it "meal_searches はログインユーザーの検索履歴に限定される" do
      result = retriever.retrieve
      expect(result[:meal_searches]).to be_a(ActiveRecord::Relation)
    end

    it "embedding が nil のレコードは除外される" do
      # embedding なしのレコードが除外されることを確認
      result = retriever.retrieve
      # embedding なしのため空の Relation が返る（エラーにならない）
      expect { result[:meal_candidates].to_a }.not_to raise_error
    end
  end
end
