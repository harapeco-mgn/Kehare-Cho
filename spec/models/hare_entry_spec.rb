require 'rails_helper'

RSpec.describe HareEntry, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }

  describe 'associations' do
    it 'belongs to user' do
      hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
      expect(hare_entry.user).to eq(user)
    end

    it { is_expected.to have_many(:hare_entry_tags).dependent(:destroy) }
    it { is_expected.to have_many(:hare_tags).through(:hare_entry_tags) }
    it { is_expected.to have_many(:point_transactions).dependent(:destroy) }
    it { is_expected.to have_one_attached(:photo) }

    it 'destroys associated hare_entry_tags when destroyed' do
      hare_entry = create(:hare_entry, user: user)
      hare_tag = create(:hare_tag)
      create(:hare_entry_tag, hare_entry: hare_entry, hare_tag: hare_tag)

      expect { hare_entry.destroy }.to change { HareEntryTag.count }.by(-1)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
      expect(hare_entry).to be_valid
    end

    it 'is invalid without body' do
      hare_entry = HareEntry.new(user: user, body: nil, occurred_on: Date.today)
      expect(hare_entry).not_to be_valid
      expect(hare_entry.errors[:body]).to include('を入力してください')
    end

    it 'is invalid when body is longer than 280 characters' do
      hare_entry = HareEntry.new(user: user, body: 'a' * 281, occurred_on: Date.today)
      expect(hare_entry).not_to be_valid
      expect(hare_entry.errors[:body]).to include('は280文字以内で入力してください')
    end

    it 'is invalid without occurred_on' do
      hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: nil)
      expect(hare_entry).not_to be_valid
      expect(hare_entry.errors[:occurred_on]).to include('を入力してください')
    end

    describe 'photo validations' do
      it 'is valid with jpeg image' do
        hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
        hare_entry.photo.attach(
          io: StringIO.new('fake image content'),
          filename: 'test.jpg',
          content_type: 'image/jpeg'
        )
        expect(hare_entry).to be_valid
      end

      it 'is valid with png image' do
        hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
        hare_entry.photo.attach(
          io: StringIO.new('fake image content'),
          filename: 'test.png',
          content_type: 'image/png'
        )
        expect(hare_entry).to be_valid
      end

      it 'is valid with webp image' do
        hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
        hare_entry.photo.attach(
          io: StringIO.new('fake image content'),
          filename: 'test.webp',
          content_type: 'image/webp'
        )
        expect(hare_entry).to be_valid
      end

      it 'is invalid with gif image' do
        hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
        hare_entry.photo.attach(
          io: StringIO.new('fake image content'),
          filename: 'test.gif',
          content_type: 'image/gif'
        )
        expect(hare_entry).not_to be_valid
        expect(hare_entry.errors[:photo]).to be_present
      end

      it 'is invalid with pdf file' do
        hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
        hare_entry.photo.attach(
          io: StringIO.new('fake pdf content'),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        expect(hare_entry).not_to be_valid
        expect(hare_entry.errors[:photo]).to be_present
      end

      it 'is invalid when photo size exceeds 5MB' do
        hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
        large_content = 'a' * (5.megabytes + 1)
        hare_entry.photo.attach(
          io: StringIO.new(large_content),
          filename: 'large.jpg',
          content_type: 'image/jpeg'
        )
        expect(hare_entry).not_to be_valid
        expect(hare_entry.errors[:photo]).to be_present
      end

      it 'is valid without photo (photo is optional)' do
        hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
        expect(hare_entry).to be_valid
      end
    end
  end

  describe 'enums' do
    it 'defines visibility enum' do
      expect(HareEntry.visibilities).to eq({ 'public_post' => 0, 'private_post' => 1 })
    end

    it 'can be set to public_post' do
      hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today, visibility: :public_post)
      expect(hare_entry.public_post?).to be true
    end

    it 'can be set to private_post' do
      hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today, visibility: :private_post)
      expect(hare_entry.private_post?).to be true
    end
  end
end
