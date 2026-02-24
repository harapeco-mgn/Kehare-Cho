require 'rails_helper'

RSpec.describe "ハレ投稿削除", type: :system do
  let(:user)       { create(:user) }
  let!(:hare_entry) { create(:hare_entry, user: user, body: "削除対象の投稿") }

  before { login_as user, scope: :user }

  scenario "詳細ページから削除するとハレ一覧から消える" do
    visit hare_entry_path(hare_entry)

    # data-turbo-confirm が window.confirm() を呼ぶため、
    # JS で window.confirm を事前に true 返却に override してダイアログをスキップ
    # （Selenium Remote では accept_confirm のタイミングが不安定になる場合がある）
    page.execute_script("window.confirm = function() { return true; }")
    click_button "削除"

    # 削除成功 → 一覧ページにリダイレクト＋フラッシュ
    expect(page).to have_current_path(hare_entries_path)
    expect(page).to have_text("ハレの記録を削除しました")
    expect(page).not_to have_text("削除対象の投稿")
  end
end
