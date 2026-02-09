require 'rails_helper'

RSpec.describe PointTransaction, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:hare_entry) }
    it { is_expected.to belong_to(:point_rule) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:awarded_on) }
    it { is_expected.to validate_presence_of(:points) }
  end

  describe 'database constraints' do
    let(:user) { create(:user) }
    let(:hare_entry) { create(:hare_entry, user: user) }
    let(:point_rule) { create(:point_rule) }

    it 'requires user_id at database level' do
      transaction = PointTransaction.new(
        user_id: nil,
        hare_entry: hare_entry,
        point_rule: point_rule,
        awarded_on: Date.current,
        points: 10
      )
      expect { transaction.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires hare_entry_id at database level' do
      transaction = PointTransaction.new(
        user: user,
        hare_entry_id: nil,
        point_rule: point_rule,
        awarded_on: Date.current,
        points: 10
      )
      expect { transaction.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires point_rule_id at database level' do
      transaction = PointTransaction.new(
        user: user,
        hare_entry: hare_entry,
        point_rule_id: nil,
        awarded_on: Date.current,
        points: 10
      )
      expect { transaction.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires awarded_on at database level' do
      transaction = PointTransaction.new(
        user: user,
        hare_entry: hare_entry,
        point_rule: point_rule,
        awarded_on: nil,
        points: 10
      )
      expect { transaction.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end

    it 'requires points at database level' do
      transaction = PointTransaction.new(
        user: user,
        hare_entry: hare_entry,
        point_rule: point_rule,
        awarded_on: Date.current,
        points: nil
      )
      expect { transaction.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end

  describe 'instance creation' do
    let(:user) { create(:user) }
    let(:hare_entry) { create(:hare_entry, user: user) }
    let(:point_rule) { create(:point_rule) }

    it 'creates a valid point transaction with all required attributes' do
      point_transaction = PointTransaction.create!(
        user: user,
        hare_entry: hare_entry,
        point_rule: point_rule,
        awarded_on: Date.current,
        points: 10
      )

      expect(point_transaction).to be_persisted
      expect(point_transaction.user).to eq(user)
      expect(point_transaction.hare_entry).to eq(hare_entry)
      expect(point_transaction.point_rule).to eq(point_rule)
      expect(point_transaction.awarded_on).to eq(Date.current)
      expect(point_transaction.points).to eq(10)
    end

    it 'allows negative points for future extensibility' do
      point_transaction = PointTransaction.create!(
        user: user,
        hare_entry: hare_entry,
        point_rule: point_rule,
        awarded_on: Date.current,
        points: -5
      )

      expect(point_transaction).to be_persisted
      expect(point_transaction.points).to eq(-5)
    end
  end
end
