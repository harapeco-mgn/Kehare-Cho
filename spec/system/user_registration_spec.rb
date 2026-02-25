require 'rails_helper'

RSpec.describe "ユーザー登録", type: :system do
  scenario "トップページから新規登録してホーム画面に遷移する" do
    visit root_path

    # トップページの「無料で始める」ボタンから登録フォームへ
    # ページに2つ存在するため（ヒーローセクション・CTAセクション）、最初のリンクを使う
    all(:link, "無料で始める").first.click
    expect(page).to have_current_path(new_user_registration_path)

    # 登録フォームに入力
    fill_in "メールアドレス", with: "newuser@example.com"
    fill_in "ニックネーム",   with: "新規ユーザー"
    fill_in "パスワード",     with: "password"
    fill_in "パスワード（確認）", with: "password"

    click_button "アカウント登録"

    # 登録成功 → 使い方ページにリダイレクト＋フラッシュ
    expect(page).to have_current_path(how_to_use_path)
    expect(page).to have_text("ようこそケハレ帖へ！")
    expect(page).to have_text("ケハレ帖の使い方")
  end
end
