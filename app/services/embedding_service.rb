class EmbeddingService
  EMBEDDING_MODEL = "text-embedding-004"

  # テキストをベクトル（768次元）に変換する
  # @param text [String] 変換対象のテキスト
  # @return [Array<Float>] 768次元のベクトル
  def self.generate(text)
    result = RubyLLM.embed(text.to_s, model: EMBEDDING_MODEL)
    result.vectors
  end
end
