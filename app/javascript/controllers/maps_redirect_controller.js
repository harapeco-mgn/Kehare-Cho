import { Controller } from "@hotwired/stimulus"

// 中食選択時に Google Maps へ自動リダイレクトする Stimulus コントローラー
// 使い方: data-controller="maps-redirect" data-maps-redirect-url-value="<URL>" を要素に追加
export default class extends Controller {
  static values = { url: String }

  connect() {
    // 2秒後に Google Maps へ自動遷移
    this.timer = setTimeout(() => {
      window.location.href = this.urlValue
    }, 2000)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
