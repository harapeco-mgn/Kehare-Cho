class EmbeddingService
  # gemini-embedding-001 は Gemini API 経由で利用可能なモデル（768次元）
  # text-embedding-004 は ruby_llm のモデルレジストリに存在せず VertexAI にルートされるため使用不可
  EMBEDDING_MODEL = "gemini-embedding-001"

  # テキストをベクトル（768次元）に変換する
  # @param text [String] 変換対象のテキスト
  # @return [Array<Float>] 768次元のベクトル
  def self.generate(text)
    result = RubyLLM.embed(text.to_s, model: EMBEDDING_MODEL)
    result.vectors
  end
end
