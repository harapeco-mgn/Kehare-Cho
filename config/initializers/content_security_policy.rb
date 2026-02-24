# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    # Cloudinary（画像CDN）からの画像配信を許可
    policy.img_src     :self, :https, :data, "res.cloudinary.com"
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https
    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts/styles.
  # Railsのimportmap・インラインスクリプトがブロックされないよう nonce を付与する
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # 違反をブロックせず、ログに記録するだけの Report-Only モードで動作させる
  # 本番環境での影響を確認後、true → false に変更して強制モードに切り替える
  config.content_security_policy_report_only = true
end
