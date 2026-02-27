require "rails_helper"

RSpec.describe ReflectionPromptBuilder do
  let(:user) { create(:user) }

  describe "#build" do
    context "ハレ記録がある場合" do
      let(:tag) { create(:hare_tag, label: "和食") }
      let(:entry) do
        e = create(:hare_entry, user: user, occurred_on: 1.day.ago, body: "鶏の唐揚げを作った")
        create(:hare_entry_tag, hare_entry: e, hare_tag: tag)
        e
      end
      let(:entries) { [ entry ] }
      let(:builder) { described_class.new(user: user, hare_entries: entries) }

      it "システムプロンプトを返す" do
        result = builder.build
        expect(result).to include("食生活分析アシスタント")
      end

      it "ハレ記録のコンテキストを含む" do
        result = builder.build
        expect(result).to include("鶏の唐揚げを作った")
      end

      it "タグ情報を含む" do
        result = builder.build
        expect(result).to include("和食")
      end

      it "分析の構成ガイドラインを含む" do
        result = builder.build
        expect(result).to include("食の傾向")
        expect(result).to include("バランスの観点")
        expect(result).to include("おすすめ")
      end
    end

    context "ハレ記録がない場合" do
      let(:builder) { described_class.new(user: user, hare_entries: []) }

      it "記録コンテキストなしでプロンプトを返す" do
        result = builder.build
        expect(result).to include("食生活分析アシスタント")
        expect(result).not_to include("【ユーザーの直近のハレ記録】")
      end
    end
  end
end
