require "rails_helper"

RSpec.describe EmbeddingService do
  let(:dummy_vector) { Array.new(768, 0.1) }

  describe ".generate" do
    it "テキストを768次元のベクトルに変換する" do
      allow(RubyLLM).to receive(:embed).and_return(
        instance_double(RubyLLM::Embedding, vectors: dummy_vector)
      )

      result = EmbeddingService.generate("疲れた日に簡単なもの")
      expect(result).to eq(dummy_vector)
      expect(result.length).to eq(768)
    end

    it "text-embedding-004 モデルを使用する" do
      expect(RubyLLM).to receive(:embed).with(
        "テストテキスト",
        model: "text-embedding-004"
      ).and_return(
        instance_double(RubyLLM::Embedding, vectors: dummy_vector)
      )

      EmbeddingService.generate("テストテキスト")
    end

    it "nil を渡しても空文字として処理する" do
      expect(RubyLLM).to receive(:embed).with(
        "",
        model: "text-embedding-004"
      ).and_return(
        instance_double(RubyLLM::Embedding, vectors: dummy_vector)
      )

      EmbeddingService.generate(nil)
    end
  end
end
