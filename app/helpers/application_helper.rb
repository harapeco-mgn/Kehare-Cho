module ApplicationHelper
  # Lucide SVG アイコンを描画するラッパーヘルパー
  # @param name [String] Lucide アイコン名（例: "sparkles", "bot"）
  # @param css_class [String] Tailwind CSS クラス（デフォルト: インラインテキスト用サイズ）
  # @param options [Hash] その他の HTML 属性（aria-label 等）
  def app_icon(name, css_class: "w-5 h-5 inline-block", **options)
    lucide_icon(name, class: css_class, **options)
  end
end
