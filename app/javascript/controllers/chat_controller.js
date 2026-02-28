import { Controller } from "@hotwired/stimulus"

// チャット UI の制御
// - メッセージ一覧の末尾へ自動スクロール（Turbo Stream 更新時も含む）
// - 送信中の二重送信防止とフォーム状態管理
// - テキストエリアの自動リサイズ
// - タイピングインジケーター消失時のフォーム再有効化
export default class extends Controller {
  static targets = ["messages", "input", "submit"]

  connect() {
    this.scrollToBottom()
    this.inputTarget.focus()
    this.observeMessages()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  // MutationObserver でメッセージ一覧の変化を監視する
  // - 新しいメッセージ追加時に自動スクロール
  // - タイピングインジケーター消失時にフォームを再有効化
  observeMessages() {
    if (!this.hasMessagesTarget) return

    this.observer = new MutationObserver(() => {
      this.scrollToBottom()

      // タイピングインジケーターが消えたらフォームを再有効化
      const typingIndicator = document.getElementById("typing_indicator")
      if (!typingIndicator && this.hasSubmitTarget) {
        this.submitTarget.disabled = false
        this.submitTarget.textContent = "送信"
        if (this.hasInputTarget) {
          this.inputTarget.focus()
        }
      }
    })

    this.observer.observe(this.messagesTarget, { childList: true, subtree: true })
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
