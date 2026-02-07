require 'rails_helper'

RSpec.describe HareEntry, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }

  describe 'associations' do
    it 'belongs to user' do
      hare_entry = HareEntry.new(user: user, body: 'テスト', occurred_on: Date.today)
      expect(hare_entry.user).to eq(user)
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
