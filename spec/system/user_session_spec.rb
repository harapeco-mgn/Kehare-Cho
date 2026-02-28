require 'rails_helper'

RSpec.describe "ログイン / ログアウト", type: :system do
  let(:user) { create(:user) }

  scenario "ログインフォームから認証してホーム画面に遷移する" do
    visit new_user_session_path

    fill_in "メールアドレス", with: user.email
    fill_in "パスワード",     with: "password"
    click_button "ログイン"

    # ログイン成功 → ホーム画面＋フラッシュ
    expect(page).to have_text("おかえりなさい！")
    expect(page).to have_text("こんにちは")
  end

  scenario "ログアウトボタンを押すとトップページに戻る" do
    # login_as はログアウト後に Warden がセッションを再注入して失敗するため、
    # フォームから実際にログインしてセッションクッキーを確立してからログアウトする
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード",     with: "password"
    click_button "ログイン"
    expect(page).to have_text("こんにちは")

    # ヘッダーのログアウトボタンをクリック
    # モバイル/デスクトップの2つのログアウトボタンが存在するため、
    # 表示状態のボタンを all で取得して最後のもの（デスクトップ用）をクリック
    all("button[type='submit']", text: "ログアウト", visible: :visible).last.click

    # ログアウト成功 → ルートページ（LP）にリダイレクト＋フラッシュ
    # devise.ja.yml の signed_out キー: "ログアウトしました。またお待ちしています"
    expect(page).to have_text("ログアウトしました。")
    expect(page).to have_text("ケハレ帖")
  end
end
