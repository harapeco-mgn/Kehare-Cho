require 'rails_helper'

RSpec.describe HareTag, type: :model do
  describe 'バリデーション' do
    describe 'key' do
      it '必須であること' do
        tag = HareTag.new(key: nil, label: 'テスト')
        expect(tag).not_to be_valid
        expect(tag.errors[:key]).to include('を入力してください')
      end

      it '重複不可であること' do
        HareTag.create!(key: 'test', label: 'テスト1')
        tag = HareTag.new(key: 'test', label: 'テスト2')
        expect(tag).not_to be_valid
        expect(tag.errors[:key]).to include('はすでに存在します')
      end

      it '英小文字で始まること' do
        tag = HareTag.new(key: 'Test', label: 'テスト')
        expect(tag).not_to be_valid
        expect(tag.errors[:key]).to include('は不正な値です')
      end

      it '英小文字・数字・アンダースコアのみ許可すること' do
        valid_keys = %w[test test123 test_key test_123]
        valid_keys.each do |key|
          tag = HareTag.new(key: key, label: "テスト#{key}")
          expect(tag).to be_valid, "#{key} は有効であるべき"
        end

        invalid_keys = [ 'Test', 'test-key', 'test key', 'test!' ]
        invalid_keys.each do |key|
          tag = HareTag.new(key: key, label: "テスト#{key}")
          expect(tag).not_to be_valid, "#{key} は無効であるべき"
        end
      end
    end

    describe 'label' do
      it '必須であること' do
        tag = HareTag.new(key: 'test', label: nil)
        expect(tag).not_to be_valid
        expect(tag.errors[:label]).to include('を入力してください')
      end

      it '重複不可であること' do
        HareTag.create!(key: 'test1', label: 'テスト')
        tag = HareTag.new(key: 'test2', label: 'テスト')
        expect(tag).not_to be_valid
        expect(tag.errors[:label]).to include('はすでに存在します')
      end
    end

    describe 'is_active' do
      it 'デフォルト値が true であること' do
        tag = HareTag.new(key: 'test', label: 'テスト')
        expect(tag.is_active).to be true
      end
    end
  end

  describe 'スコープ' do
    before do
      HareTag.destroy_all
      HareTag.create!(key: 'active1', label: '有効1', is_active: true, position: 2)
      HareTag.create!(key: 'active2', label: '有効2', is_active: true, position: 1)
      HareTag.create!(key: 'inactive1', label: '無効1', is_active: false, position: 3)
    end

    describe '.active' do
      it 'is_active が true のタグのみ返すこと' do
        tags = HareTag.active
        expect(tags.count).to eq(2)
        expect(tags.pluck(:key)).to contain_exactly('active1', 'active2')
      end
    end

    describe '.sorted' do
      it 'position の昇順で返すこと' do
        tags = HareTag.sorted
        expect(tags.pluck(:key)).to eq([ 'active2', 'active1', 'inactive1' ])
      end
    end

    describe '.active.sorted' do
      it 'チェーン可能で、有効なタグを position 順で返すこと' do
        tags = HareTag.active.sorted
        expect(tags.pluck(:key)).to eq([ 'active2', 'active1' ])
      end
    end
  end
end
