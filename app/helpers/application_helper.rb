module ApplicationHelper
  # Lucide SVG アイコンを描画するラッパーヘルパー
  # @param name [String] Lucide アイコン名（例: "sparkles", "bot"）
  # @param css_class [String] Tailwind CSS クラス（デフォルト: インラインテキスト用サイズ）
  # @param options [Hash] その他の HTML 属性（aria-label 等）
  def app_icon(name, css_class: "w-5 h-5 inline-block", **options)
    lucide_icon(name, class: css_class, **options)
  end

  # X（Twitter）シェア用テキストを生成する
  # 本文（改行→スペース変換、100文字truncate）+ 日付 + ハッシュタグの構成
  # @param entry [HareEntry] ハレ投稿
  # @return [String] シェア用テキスト
  def x_share_text(entry)
    body_text = entry.body.gsub(/\r?\n/, " ").truncate(200)
    date_text = entry.occurred_on.strftime("%Y年%-m月%-d日")
    "#{body_text}\n\n#{date_text}のハレ記録 #ケハレ帖"
  end

  # 本文中の URL を自動リンク化する
  # h() でエスケープ → auto_link で URL 検出 → sanitize で <a> タグのみ許可（XSS 対策）
  # @param text [String] 本文テキスト
  # @return [ActiveSupport::SafeBuffer] リンク化済みの HTML
  def linkify_body(text)
    escaped = h(text)
    linked = auto_link(escaped, html: { target: "_blank", rel: "noopener noreferrer", class: "text-[#C87941] underline break-all" }, sanitize: false)
    sanitize(linked, tags: %w[a br], attributes: %w[href target rel class])
  end
end
