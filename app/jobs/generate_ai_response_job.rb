class GenerateAiResponseJob < ApplicationJob
  queue_as :default

  # AI 応答を非同期で生成し、Turbo Streams でリアルタイム配信する
  # システムプロンプトとユーザーメッセージはコントローラーで保存済み
  def perform(chat_id, _user_id)
    chat = Chat.find(chat_id)

    # AI 応答を生成（コントローラーで保存したメッセージを元に complete を呼び出す）
    chat.complete

    # 生成された AI メッセージを取得
    ai_message = chat.messages.order(:id).last

    # タイピングインジケーターを AI メッセージで置換してブロードキャスト
    Turbo::StreamsChannel.broadcast_replace_to(
      chat,
      target: "typing_indicator",
      partial: "messages/assistant_message",
      locals: { message: ai_message, chat: chat }
    )
  rescue RubyLLM::RateLimitError
    # レート制限エラー: タイピングインジケーターをエラーメッセージで置換
    Turbo::StreamsChannel.broadcast_replace_to(
      chat,
      target: "typing_indicator",
      html: error_html("AIが混み合っています。少し時間をおいてから再度お試しください。")
    )
  rescue StandardError
    # その他のエラー
    Turbo::StreamsChannel.broadcast_replace_to(
      chat,
      target: "typing_indicator",
      html: error_html("エラーが発生しました。ページを再読み込みしてお試しください。")
    )
    raise
  end

private

  def error_html(message)
    <<~HTML
      <div id="typing_indicator" class="flex items-start gap-2">
        <div class="w-8 h-8 rounded-full bg-red-100 flex items-center justify-center flex-shrink-0 mt-1">
          <span class="text-sm">⚠️</span>
        </div>
        <div class="bg-red-50 border border-red-200 rounded-2xl rounded-bl-sm px-4 py-3">
          <p class="text-sm text-red-600">#{message}</p>
        </div>
      </div>
    HTML
  end
end
