import { Controller } from "@hotwired/stimulus"

// クリップボードへのコピー機能
export default class extends Controller {
  static targets = ["button", "feedback"]
  static values = { text: String }

  copy() {
    navigator.clipboard.writeText(this.textValue).then(() => {
      this.feedbackTarget.classList.remove("hidden")
      setTimeout(() => {
        this.feedbackTarget.classList.add("hidden")
      }, 2000)
    })
  }
}
