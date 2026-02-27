import { Controller } from "@hotwired/stimulus"

// チャット UI の制御
// - メッセージ一覧の末尾へ自動スクロール
// - 送信中の二重送信防止
// - テキストエリアの自動リサイズ
export default class extends Controller {
  static targets = ["messages", "input", "submit"]

  connect() {
    this.scrollToBottom()
    this.inputTarget.focus()
  }

  // メッセージ一覧の末尾へスクロール
  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  // フォーム送信時: ボタンを無効化して二重送信を防ぐ
  submit(event) {
    const content = this.inputTarget.value.trim()
    if (!content) {
      event.preventDefault()
      return
    }
    this.submitTarget.disabled = true
    this.submitTarget.textContent = "送信中..."
  }

  // テキストエリアの高さを内容に合わせて自動調整
  resize() {
    this.inputTarget.style.height = "auto"
    this.inputTarget.style.height = `${this.inputTarget.scrollHeight}px`
  }

  // Ctrl+Enter または Cmd+Enter で送信
  handleKeydown(event) {
    if ((event.ctrlKey || event.metaKey) && event.key === "Enter") {
      this.element.querySelector("form").requestSubmit()
    }
  }
}
