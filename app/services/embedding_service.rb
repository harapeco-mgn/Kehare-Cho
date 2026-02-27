class EmbeddingService
  # text-embedding-004: Gemini API が提供する 768 次元埋め込みモデル
  # ruby_llm のモデルレジストリに未登録のため VertexAI にルーティングされる問題を回避し、
  # Gemini REST API へ直接 HTTP リクエストを送信する
  EMBEDDING_MODEL = "text-embedding-004"
  GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta/models"

  # テキストをベクトル（768次元）に変換する
  # @param text [String] 変換対象のテキスト
  # @return [Array<Float>] 768次元のベクトル
  def self.generate(text)
    api_key = ENV.fetch("GEMINI_API_KEY")
    uri = URI("#{GEMINI_API_BASE}/#{EMBEDDING_MODEL}:embedContent?key=#{api_key}")
    body = {
      model: "models/#{EMBEDDING_MODEL}",
      content: { parts: [ { text: text.to_s } ] }
    }.to_json
    response = Net::HTTP.post(uri, body, "Content-Type" => "application/json")
    JSON.parse(response.body).dig("embedding", "values")
  end
end
