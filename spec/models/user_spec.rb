require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:hare_entries).dependent(:destroy) }
    it { is_expected.to have_many(:point_transactions).dependent(:destroy) }
  end
end
