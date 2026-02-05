# frozen_string_literal: true

# Resend API の設定
# 本番環境でのメール送信に使用
if Rails.env.production?
  Resend.api_key = ENV.fetch("RESEND_API_KEY")
end
