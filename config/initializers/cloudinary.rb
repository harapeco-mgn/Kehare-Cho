# frozen_string_literal: true

if Rails.env.production?
  # 本番環境: 実際の Cloudinary 認証情報を使用
  Cloudinary.config do |config|
    config.cloud_name = ENV.fetch("CLOUDINARY_CLOUD_NAME", nil)
    config.api_key = ENV.fetch("CLOUDINARY_API_KEY", nil)
    config.api_secret = ENV.fetch("CLOUDINARY_API_SECRET", nil)
    config.secure = true
  end
elsif Rails.env.test?
  # テスト環境: ダミーの設定（実際のアップロードは行わない）
  Cloudinary.config do |config|
    config.cloud_name = "test-cloud"
    config.api_key = "test-api-key"
    config.api_secret = "test-api-secret"
    config.secure = true
  end
end
