import { Controller } from "@hotwired/stimulus"

// テキストエリアの残り文字数をリアルタイム表示する Stimulus コントローラー
// 使い方: data-controller="character-count" を親要素に追加
export default class extends Controller {
  static targets = ["input", "count"]

  // コントローラーが接続されたとき（ページ読み込み時）に呼ばれる
  // 編集フォームで既存テキストがある場合の初期カウントを表示する
  connect() {
    this.update()
  }

  // input イベントで呼ばれるメソッド
  // data-action="input->character-count#update" で紐付け
  update() {
    const current = this.inputTarget.value.length
    const max = this.inputTarget.maxLength
    const remaining = max - current

    this.countTarget.textContent = remaining
    this.#updateColor(remaining)
  }

  // 残り文字数に応じてカウント表示の色を切り替える
  #updateColor(remaining) {
    this.countTarget.classList.remove("text-gray-400", "text-orange-500", "text-red-500")

    if (remaining <= 0) {
      this.countTarget.classList.add("text-red-500")
    } else if (remaining <= 20) {
      this.countTarget.classList.add("text-orange-500")
    } else {
      this.countTarget.classList.add("text-gray-400")
    }
  }
}
