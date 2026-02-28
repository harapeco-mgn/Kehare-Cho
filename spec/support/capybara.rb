# システムスペック用ドライバ設定
#
# 環境別の使い分け：
#   CI（GitHub Actions / ubuntu-latest）
#     → Selenium headless Chrome
#       browser-actions/setup-chrome がインストールした Chrome を BROWSER_PATH で指定
#       ChromeDriver は Selenium Manager が自動的にバージョンを合わせてダウンロード
#   ローカル（WSL2 + Docker）
#     → Selenium Remote（selenium/standalone-chrome コンテナに接続）
#       WSL2 カーネルの seccomp 制限により Chrome を直接起動できないため、
#       コンテナ化された Chrome を使うことで制限を回避する

Capybara.default_max_wait_time = 10
Capybara.server = :puma, { Silent: true }

if ENV["CI"]
  # ─── CI 環境: Selenium headless Chrome ───────────────────────────────────
  require "selenium/webdriver"

  Capybara.register_driver(:selenium_chrome_headless) do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")              # CI の実行環境で必要
    options.add_argument("--disable-setuid-sandbox")  # Chromium でのクラッシュ対策
    options.add_argument("--disable-dev-shm-usage")   # /dev/shm が小さい環境向け
    options.add_argument("--disable-gpu")             # ヘッドレスの安定性向上
    options.add_argument("--window-size=1400,900")

    # setup-chrome は "chrome" という名前でインストールするため BROWSER_PATH で明示指定
    # ChromeDriver は Selenium Manager が options.binary のバージョンに合わせて自動管理する
    chrome_path = ENV.fetch("BROWSER_PATH", nil)
    options.binary = chrome_path if chrome_path

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  RSpec.configure do |config|
    config.before(:each, type: :system) do
      driven_by :selenium_chrome_headless
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
