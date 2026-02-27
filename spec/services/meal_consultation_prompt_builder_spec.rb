require "rails_helper"

RSpec.describe MealConsultationPromptBuilder do
  let(:user) { create(:user) }
  let(:empty_rag_context) { { meal_candidates: [], hare_entries: [], meal_searches: [] } }

  describe "#build" do
    context "RAG コンテキストが空の場合" do
      subject(:prompt) do
        MealConsultationPromptBuilder.new(
          user: user,
          conversation_type: "meal_consultation",
          rag_context: empty_rag_context
        ).build
      end

      it "基本システムプロンプトを含む" do
        expect(prompt).to include("ケハレ帖")
      end

      it "献立相談アシスタントのロールを含む" do
        expect(prompt).to include("献立相談アシスタント")
      end

      it "出力ガイドラインを含む" do
        expect(prompt).to include("回答ガイドライン")
      end
    end

    context "conversation_type が cooking_advice の場合" do
      subject(:prompt) do
        MealConsultationPromptBuilder.new(
          user: user,
          conversation_type: "cooking_advice",
          rag_context: empty_rag_context
        ).build
      end

      it "料理アドバイザーのロールを含む" do
        expect(prompt).to include("料理アドバイザー")
      end
    end

    context "conversation_type が reflection の場合" do
      subject(:prompt) do
        MealConsultationPromptBuilder.new(
          user: user,
          conversation_type: "reflection",
          rag_context: empty_rag_context
        ).build
      end

      it "食生活分析アシスタントのロールを含む" do
        expect(prompt).to include("食生活分析アシスタント")
      end
    end

    context "RAG コンテキストにデータがある場合" do
      let(:meal_candidate) do
        instance_double(MealCandidate,
          name: "鶏の照り焼き",
          search_hint: "簡単 時短")
      end
      let(:rag_context) do
        { meal_candidates: [ meal_candidate ], hare_entries: [], meal_searches: [] }
      end

      subject(:prompt) do
        MealConsultationPromptBuilder.new(
          user: user,
          conversation_type: "meal_consultation",
          rag_context: rag_context
        ).build
      end

      it "献立候補セクションを含む" do
        expect(prompt).to include("参考にできる献立候補")
      end

      it "候補の料理名を含む" do
        expect(prompt).to include("鶏の照り焼き")
      end
    end
  end
end
