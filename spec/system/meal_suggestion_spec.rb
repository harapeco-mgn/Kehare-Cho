require 'rails_helper'

RSpec.describe "献立提案（自炊）", type: :system do
  let(:user)  { create(:user) }
  let!(:genre) { create(:genre) }
  # ピッカーが 3 件返せるよう self_cook かつ 30 分以内の候補を用意
  let!(:candidates) do
    create_list(:meal_candidate, 3, genre: genre, cook_context: :self_cook, minutes_max: 30)
  end

  before { login_as user, scope: :user }

  scenario "自炊の条件を入力して献立候補が表示される" do
    visit new_meal_search_path

    # sr-only なラジオボタンはラベルクリックで操作
    find('label', text: '自炊する').click

    # 所要時間・ジャンルを選択
    # form_with url: 指定のため、Rails がプレフィックスを付与しない
    # セレクトボックスの id は "required_minutes", "genre_id" になる
    select '30',        from: 'required_minutes'
    select genre.label, from: 'genre_id'

    click_button '候補を見る'

    # 成功 → 献立相談ログページ（meal_searches#index）にリダイレクト
    expect(page).to have_current_path(meal_searches_path)

    # 提案された候補名が表示されている
    candidates.each do |candidate|
      expect(page).to have_text(candidate.name)
    end
  end
end
