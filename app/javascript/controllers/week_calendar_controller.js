import { Controller } from "@hotwired/stimulus"

// 週間カレンダーのホバーでエントリープレビューを切り替えるコントローラー
export default class extends Controller {
  static targets = ["defaultPreview", "entryPreview"]

  // 日付円にホバー → 対応するエントリーを表示
  show(event) {
    const entryId = String(event.params.entryId)
    this.defaultPreviewTarget.classList.add("hidden")
    this.entryPreviewTargets.forEach(el => {
      if (el.dataset.entryId === entryId) {
        el.classList.remove("hidden")
      } else {
        el.classList.add("hidden")
      }
    })
  }

  // ホバーを外す → デフォルト表示に戻す
  reset() {
    this.defaultPreviewTarget.classList.remove("hidden")
    this.entryPreviewTargets.forEach(el => el.classList.add("hidden"))
  }
}
