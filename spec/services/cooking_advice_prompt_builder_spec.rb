require "rails_helper"

RSpec.describe CookingAdvicePromptBuilder do
  let(:user) { build(:user) }
  subject(:builder) { described_class.new(user: user) }

  describe "#build" do
    let(:prompt) { builder.build }

    it "料理アドバイザーとしての役割を含む" do
      expect(prompt).to include("料理アドバイザー")
    end

    it "食材の使い方・保存方法に関する説明を含む" do
      expect(prompt).to include("食材")
    end

    it "調理法・代替材料に関する説明を含む" do
      expect(prompt).to include("調理")
    end

    it "料理初心者向けの説明を含む" do
      expect(prompt).to include("初心者")
    end

    it "回答ガイドラインを含む" do
      expect(prompt).to include("ガイドライン")
    end

    it "空文字列を返さない" do
      expect(prompt).not_to be_empty
    end
  end
end
