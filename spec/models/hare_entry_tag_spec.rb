require 'rails_helper'

RSpec.describe HareEntryTag, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:hare_entry) }
    it { is_expected.to belong_to(:hare_tag) }
  end

  describe 'validations' do
    subject { build(:hare_entry_tag) }

    it { is_expected.to validate_uniqueness_of(:hare_tag_id).scoped_to(:hare_entry_id) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'is invalid without hare_entry' do
      subject.hare_entry = nil
      expect(subject).not_to be_valid
    end

    it 'is invalid without hare_tag' do
      subject.hare_tag = nil
      expect(subject).not_to be_valid
    end

    it 'does not allow duplicate hare_entry_id and hare_tag_id combinations' do
      hare_entry = create(:hare_entry)
      hare_tag = create(:hare_tag)
      create(:hare_entry_tag, hare_entry: hare_entry, hare_tag: hare_tag)

      duplicate = build(:hare_entry_tag, hare_entry: hare_entry, hare_tag: hare_tag)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:hare_tag_id]).to include('はすでに存在します')
    end
  end
end
