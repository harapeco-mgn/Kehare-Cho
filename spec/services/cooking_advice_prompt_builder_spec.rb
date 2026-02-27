require "rails_helper"

RSpec.describe CookingAdvicePromptBuilder do
  let(:user) { build(:user) }
  subject(:builder) { described_class.new(user: user) }

  describe "#build" do
    let(:prompt) { builder.build }

    it "料理アドバイザーとしての役割を含む" do
      expect(prompt).to include("料理アドバイザー")
    end

    it "保存方法・調理法など質問内容に直接答える指示を含む" do
      expect(prompt).to include("保存方法・調理法")
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

    it "質問に直接答えるよう指示する" do
      expect(prompt).to include("直接答えて")
    end

    it "聞かれていないレシピ提案を禁止する指示を含む" do
      expect(prompt).to include("聞かれていないレシピ")
    end

    it "空文字列を返さない" do
      expect(prompt).not_to be_empty
    end
  end
end
