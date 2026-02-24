# システムスペック用ドライバ設定
#
# 環境別の使い分け：
#   CI（GitHub Actions / ubuntu-latest）
#     → Cuprite（CDP で Chrome と直接通信。ChromeDriver 不要で 20〜40% 高速）
#   ローカル（WSL2 + Docker）
#     → Selenium Remote（selenium/standalone-chrome コンテナに接続）
#       WSL2 カーネルの seccomp 制限により Chrome を直接起動できないため、
#       コンテナ化された Chrome を使うことで制限を回避する

Capybara.default_max_wait_time = 3
Capybara.server = :puma, { Silent: true }

if ENV["CI"]
  # ─── CI 環境: Cuprite ────────────────────────────────────────────────────
  require "capybara/cuprite"

  Capybara.register_driver(:cuprite) do |app|
    Capybara::Cuprite::Driver.new(
      app,
      window_size: [ 1400, 900 ],
      browser_options: {
        "no-sandbox" => nil,            # CI の root 実行環境で必要
        "disable-dev-shm-usage" => nil, # /dev/shm が小さい環境向け
        "disable-gpu" => nil,           # ヘッドレスの安定性向上
        "disable-extensions" => nil,    # 拡張機能を無効化して起動を高速化
        "user-data-dir" => "/tmp/chrome-data" # HOME が書き込み不可の場合の対策
      },
      headless: true,
      process_timeout: 30,
      timeout: 15
    )
  end

  RSpec.configure do |config|
    config.before(:each, type: :system) do
      driven_by :cuprite
    end
  end

else
  # ─── ローカル環境: Selenium Remote ───────────────────────────────────────
  # selenium コンテナ内の Chrome から web コンテナにアクセスするため、
  # Capybara のテスト用サーバーを 0.0.0.0 でバインドして Docker ネットワーク越しに接続できるようにする
  require "selenium/webdriver"

  Capybara.server_host = "0.0.0.0"
  Capybara.server_port = 3001
  # selenium コンテナからは「web」というホスト名で web コンテナにアクセスできる
  Capybara.app_host = "http://web:#{Capybara.server_port}"

  Capybara.register_driver(:selenium_chrome_remote) do |app|
    selenium_url = ENV.fetch("SELENIUM_REMOTE_URL", "http://selenium:4444/wd/hub")
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--window-size=1400,900")

    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: selenium_url,
      options: options
    )
  end

  RSpec.configure do |config|
    config.before(:each, type: :system) do
      driven_by :selenium_chrome_remote
    end
  end
end
