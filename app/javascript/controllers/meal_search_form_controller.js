import { Controller } from "@hotwired/stimulus"

// 献立検索フォームの動的制御
// 「外食」選択時に所要時間フィールドを非表示にする
export default class extends Controller {
  static targets = ["minutesField"]

  connect() {
    // 初期状態を設定
    this.toggleMinutes()
  }

  toggleMinutes() {
    // 選択されている cook_context の値を取得
    const selectedValue = this.element.querySelector('input[name="cook_context"]:checked')?.value

    // 「外食」(eat_out) の場合は所要時間を非表示
    const shouldHide = selectedValue === "eat_out"

    if (this.hasMinutesFieldTarget) {
      this.minutesFieldTarget.classList.toggle("hidden", shouldHide)
    }
  }
}
