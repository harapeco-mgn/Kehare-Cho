class CspReportsController < ApplicationController
  # CSP 違反レポートは認証不要（ブラウザが直接 POST するため）
  skip_before_action :authenticate_user!
  # ブラウザが送信する JSON は CSRF トークンを含まないためスキップ
  skip_before_action :verify_authenticity_token

  def create
    # CSP 違反内容をログに記録（本番環境でのデバッグ・分析に使用）
    report = JSON.parse(request.body.read)
    Rails.logger.warn "[CSP Violation] #{report.to_json}"
    head :ok
  rescue JSON::ParserError
    head :unprocessable_entity
  end
end
