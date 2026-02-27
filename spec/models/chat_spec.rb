require "rails_helper"

RSpec.describe Chat, type: :model do
  describe "アソシエーション" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:messages) }
  end

  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:user) }
  end

  describe "enum: conversation_type" do
    it "デフォルト値は meal_consultation" do
      chat = build(:chat)
      expect(chat.conversation_type).to eq("meal_consultation")
    end

    it "定義された全ての conversation_type を持つ" do
      expect(Chat.conversation_types.keys).to contain_exactly(
        "meal_consultation", "cooking_advice", "reflection"
      )
    end

    it "meal_consultation? が正しく動作する" do
      chat = build(:chat, conversation_type: :meal_consultation)
      expect(chat.meal_consultation?).to be true
      expect(chat.cooking_advice?).to be false
    end

    it "スコープ .meal_consultation が正しく動作する" do
      user = create(:user)
      meal_chat = create(:chat, user:, conversation_type: :meal_consultation)
      _other_chat = create(:chat, user:, conversation_type: :cooking_advice)
      expect(Chat.meal_consultation).to contain_exactly(meal_chat)
    end
  end
end
