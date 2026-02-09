require 'rails_helper'

RSpec.describe PointRule, type: :model do
  describe 'アソシエーション' do
    it { is_expected.to have_many(:point_transactions).dependent(:restrict_with_error) }
  end

  describe 'バリデーション' do
    describe 'key' do
      it '必須であること' do
        rule = PointRule.new(key: nil, label: 'テスト', points: 1, priority: 1)
        expect(rule).not_to be_valid
        expect(rule.errors[:key]).to include('を入力してください')
      end

      it '重複不可であること' do
        PointRule.create!(key: 'test', label: 'テスト1', points: 1, priority: 1)
        rule = PointRule.new(key: 'test', label: 'テスト2', points: 1, priority: 2)
        expect(rule).not_to be_valid
        expect(rule.errors[:key]).to include('はすでに存在します')
      end

      it '英小文字で始まること' do
        rule = PointRule.new(key: 'Test', label: 'テスト', points: 1, priority: 1)
        expect(rule).not_to be_valid
        expect(rule.errors[:key]).to include('は不正な値です')
      end

      it '英小文字・数字・アンダースコアのみ許可すること' do
        valid_keys = %w[test test123 test_key test_123]
        valid_keys.each do |key|
          rule = PointRule.new(key: key, label: "テスト#{key}", points: 1, priority: 1)
          expect(rule).to be_valid, "#{key} は有効であるべき"
        end

        invalid_keys = [ 'Test', 'test-key', 'test key', 'test!' ]
        invalid_keys.each do |key|
          rule = PointRule.new(key: key, label: "テスト#{key}", points: 1, priority: 1)
          expect(rule).not_to be_valid, "#{key} は無効であるべき"
        end
      end
    end

    describe 'label' do
      it '必須であること' do
        rule = PointRule.new(key: 'test', label: nil, points: 1, priority: 1)
        expect(rule).not_to be_valid
        expect(rule.errors[:label]).to include('を入力してください')
      end
    end

    describe 'points' do
      it '必須であること' do
        rule = PointRule.new(key: 'test', label: 'テスト', points: nil, priority: 1)
        expect(rule).not_to be_valid
        expect(rule.errors[:points]).to include('を入力してください')
      end
    end

    describe 'priority' do
      it '必須であること' do
        rule = PointRule.new(key: 'test', label: 'テスト', points: 1, priority: nil)
        expect(rule).not_to be_valid
        expect(rule.errors[:priority]).to include('を入力してください')
      end
    end

    describe 'is_active' do
      it 'デフォルト値が true であること' do
        rule = PointRule.new(key: 'test', label: 'テスト', points: 1, priority: 1)
        expect(rule.is_active).to be true
      end
    end
  end

  describe 'スコープ' do
    before do
      PointRule.destroy_all
      PointRule.create!(key: 'active1', label: '有効1', points: 1, is_active: true, priority: 2)
      PointRule.create!(key: 'active2', label: '有効2', points: 1, is_active: true, priority: 1)
      PointRule.create!(key: 'inactive1', label: '無効1', points: 1, is_active: false, priority: 3)
    end

    describe '.active' do
      it 'is_active が true のルールのみ返すこと' do
        rules = PointRule.active
        expect(rules.count).to eq(2)
        expect(rules.pluck(:key)).to contain_exactly('active1', 'active2')
      end
    end

    describe '.sorted' do
      it 'priority の昇順で返すこと' do
        rules = PointRule.sorted
        expect(rules.pluck(:key)).to eq([ 'active2', 'active1', 'inactive1' ])
      end
    end

    describe '.active.sorted' do
      it 'チェーン可能で、有効なルールを priority 順で返すこと' do
        rules = PointRule.active.sorted
        expect(rules.pluck(:key)).to eq([ 'active2', 'active1' ])
      end
    end
  end
end
