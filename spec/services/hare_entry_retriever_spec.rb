require "rails_helper"

RSpec.describe HareEntryRetriever do
  let(:user) { create(:user) }
  let(:retriever) { described_class.new(user: user) }

  describe "#retrieve" do
    it "直近30日のハレ記録を返す" do
      recent = create(:hare_entry, user: user, occurred_on: 1.day.ago)
      create(:hare_entry, user: user, occurred_on: 31.days.ago)
      expect(retriever.retrieve).to include(recent)
    end

    it "30日より前の記録は含まない" do
      old_entry = create(:hare_entry, user: user, occurred_on: 31.days.ago)
      expect(retriever.retrieve).not_to include(old_entry)
    end

    it "他ユーザーの記録は含まない" do
      other_user = create(:user)
      other_entry = create(:hare_entry, user: other_user, occurred_on: 1.day.ago)
      expect(retriever.retrieve).not_to include(other_entry)
    end

    it "新しい順（occurred_on 降順）で返す" do
      older = create(:hare_entry, user: user, occurred_on: 5.days.ago)
      newer = create(:hare_entry, user: user, occurred_on: 1.day.ago)
      result = retriever.retrieve.to_a
      expect(result.first).to eq(newer)
      expect(result.last).to eq(older)
    end

    it "hare_tags を eager load する" do
      entry = create(:hare_entry, user: user, occurred_on: 1.day.ago)
      tag = create(:hare_tag)
      create(:hare_entry_tag, hare_entry: entry, hare_tag: tag)
      result = retriever.retrieve.first
      expect(result.association(:hare_tags)).to be_loaded
    end
  end
end
