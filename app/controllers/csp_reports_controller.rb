class CspReportsController < ApplicationController
  # ブラウザが送信する JSON は CSRF トークンを含まないためスキップ
  # authenticate_user! は ApplicationController には未登録（各コントローラーで個別に呼ぶため不要）
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
