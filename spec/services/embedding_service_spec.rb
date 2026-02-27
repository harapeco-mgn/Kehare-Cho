require "rails_helper"

# skip_embedding_stub: true → rails_helper のグローバルスタブを除外し、
# Net::HTTP レベルでスタブして実装そのものをテストする
RSpec.describe EmbeddingService, skip_embedding_stub: true do
  let(:dummy_vector) { Array.new(768, 0.1) }
  let(:api_response_body) do
    { "embedding" => { "values" => dummy_vector } }.to_json
  end
  let(:mock_http_response) do
    instance_double(Net::HTTPResponse, body: api_response_body)
  end

  before do
    allow(Net::HTTP).to receive(:post).and_return(mock_http_response)
  end

  describe ".generate" do
    it "テキストを768次元のベクトルに変換する" do
      result = EmbeddingService.generate("疲れた日に簡単なもの")
      expect(result).to eq(dummy_vector)
      expect(result.length).to eq(768)
    end

    it "text-embedding-004 モデルを使用する" do
      expect(Net::HTTP).to receive(:post).with(
        satisfy { |uri| uri.to_s.include?("text-embedding-004") },
        anything,
        anything
      ).and_return(mock_http_response)

      EmbeddingService.generate("テストテキスト")
    end

    it "nil を渡しても空文字として処理する" do
      expect(Net::HTTP).to receive(:post).with(
        anything,
        satisfy { |body| JSON.parse(body).dig("content", "parts", 0, "text") == "" },
        anything
      ).and_return(mock_http_response)

      EmbeddingService.generate(nil)
    end
  end
end
