# ログイン試行を IP アドレスで制限（1分間に5回まで）
Rack::Attack.throttle("logins/ip", limit: 5, period: 1.minute) do |request|
  request.ip if request.path == "/users/sign_in" && request.post?
end

# ログイン試行をメールアドレスで制限（1分間に5回まで）
Rack::Attack.throttle("logins/email", limit: 5, period: 1.minute) do |request|
  if request.path == "/users/sign_in" && request.post?
    request.params.dig("user", "email")&.downcase&.strip
  end
end

# 全リクエストを IP アドレスで制限（5分間に300回まで）
Rack::Attack.throttle("req/ip", limit: 300, period: 5.minutes) do |request|
  request.ip unless request.path.start_with?("/assets")
end

# 429 レスポンスを日本語でカスタマイズ
Rack::Attack.throttled_responder = lambda do |_request|
  [
    429,
    { "Content-Type" => "text/plain; charset=utf-8" },
    [ "リクエストが多すぎます。しばらく時間をおいてから再度お試しください。\n" ]
  ]
end
