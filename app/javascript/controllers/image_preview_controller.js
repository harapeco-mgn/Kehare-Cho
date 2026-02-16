import { Controller } from "@hotwired/stimulus"

// ファイル選択時に画像プレビューを表示する Stimulus コントローラー
// 使い方: data-controller="image-preview" を親要素に追加
export default class extends Controller {
  static targets = ["input", "preview", "previewContainer"]

  // ファイル選択時に呼ばれるメソッド
  // data-action="change->image-preview#preview" で紐付け
  preview(event) {
    const file = event.target.files[0]

    // ファイルが選択されていない場合は何もしない
    if (!file) {
      this.hidePreview()
      return
    }

    // 画像ファイル以外が選択された場合は非表示
    if (!file.type.match(/^image\/(jpeg|png|webp)$/)) {
      this.hidePreview()
      return
    }

    // FileReader で画像を読み込み
    const reader = new FileReader()

    reader.addEventListener('load', (e) => {
      // Data URL を img タグの src に設定
      this.previewTarget.src = e.target.result
      this.previewContainerTarget.classList.remove('hidden')
    })

    reader.readAsDataURL(file)
  }

  // プレビューを非表示にする
  hidePreview() {
    if (this.hasPreviewTarget && this.hasPreviewContainerTarget) {
      this.previewTarget.src = ''
      this.previewContainerTarget.classList.add('hidden')
    }
  }
}
