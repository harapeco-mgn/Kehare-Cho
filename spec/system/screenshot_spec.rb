require "rails_helper"

# LP用スクリーンショット撮影スペック
# 使い方: docker compose exec web bundle exec rspec spec/system/screenshot_spec.rb --format documentation
# 出力先: public/images/screenshots/
RSpec.describe "スクリーンショット撮影", type: :system do
  SCREENSHOT_DIR = Rails.root.join("public/images/screenshots").freeze

  let(:user) do
    create(:user, nickname: "ケハレ花子")
  end

  before do
    # モバイルサイズに設定（390×844 = iPhone 14相当）
    page.driver.browser.manage.window.resize_to(390, 844)
    login_as user, scope: :user
  end

  def capture_screenshot(filename)
    sleep 0.5 # レンダリング待ち
    path = SCREENSHOT_DIR.join(filename)
    page.save_screenshot(path.to_s)
    puts "📸 保存: #{path}"
  end

  scenario "ホーム画面のスクリーンショット" do
    # テスト DB にシードがないため factory で point_rule を作成
    point_rule = create(:point_rule)
    entry1 = create(:hare_entry, user: user, body: "はじめて手作りパスタに挑戦！こねる工程が楽しかった", occurred_on: Date.current)
    entry2 = create(:hare_entry, user: user, body: "旬のたけのこで炊き込みご飯を作った", occurred_on: Date.current - 2)
    create(:point_transaction, user: user, hare_entry: entry1, point_rule: point_rule, points: 10)
    create(:point_transaction, user: user, hare_entry: entry2, point_rule: point_rule, points: 10)

    visit root_path
    capture_screenshot("home.png")
  end

  scenario "ハレ記録フォームのスクリーンショット" do
    visit new_hare_entry_path
    capture_screenshot("hare_entry.png")
  end

  scenario "献立提案結果のスクリーンショット" do
    create(:meal_search, user: user,
           presented_candidate_names: [ "親子丼", "豚汁", "ほうれん草のおひたし" ])
    visit meal_searches_path
    capture_screenshot("meal_search.png")
  end
end
