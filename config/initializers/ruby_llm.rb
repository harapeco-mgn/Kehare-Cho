RubyLLM.configure do |config|
  config.gemini_api_key = ENV.fetch("GEMINI_API_KEY", nil)
  config.default_model = "gemini-2.0-flash"

  # アソシエーションベースの acts_as API を使用（推奨）
  config.use_new_acts_as = true
end
