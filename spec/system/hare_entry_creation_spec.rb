require 'rails_helper'

RSpec.describe "ハレ投稿作成", type: :system do
  let(:user) { create(:user) }

  before { login_as user, scope: :user }

  scenario "フォームから投稿を作成して詳細ページに遷移する" do
    visit new_hare_entry_path

    fill_in "内容", with: "今日は手作りカレーに挑戦した！"
    click_button "記録する"

    # 作成成功 → 詳細ページにリダイレクト＋フラッシュ
    expect(page).to have_text("ハレを記録しました！")
    expect(page).to have_text("今日は手作りカレーに挑戦した！")
  end

  scenario "作成した投稿がハレ一覧に表示される" do
    visit new_hare_entry_path

    fill_in "内容", with: "一覧確認用の投稿"
    click_button "記録する"

    # 作成成功 → 詳細ページにリダイレクト
    expect(page).to have_text("ハレを記録しました！")

    visit hare_entries_path

    expect(page).to have_text("一覧確認用の投稿")
  end
end
