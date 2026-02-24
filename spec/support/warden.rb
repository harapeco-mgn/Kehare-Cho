# システムスペック終了後に Warden のテスト状態をリセット
# login_as ヘルパーで設定した認証状態が次のテストに漏れないように
RSpec.configure do |config|
  config.after(:each, type: :system) do
    Warden.test_reset!
  end
end
