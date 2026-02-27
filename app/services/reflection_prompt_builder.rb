class ReflectionPromptBuilder
  def initialize(user:, hare_entries:)
    @user = user
    @hare_entries = hare_entries
  end

  def build
    [
      base_instruction,
      entries_context,
      output_guidelines
    ].compact.join("\n\n")
  end

private

  def base_instruction
    <<~TEXT
      あなたは「ケハレ帖」の食生活分析アシスタントです。
      ユーザーの過去のハレ記録（食の体験メモ）を分析し、食生活の傾向とアドバイスを提供してください。
      親しみやすい口調で、具体的で前向きなフィードバックをしてください。
    TEXT
  end

  def entries_context
    return nil if @hare_entries.empty?

    list = @hare_entries.map do |e|
      tags = e.hare_tags.map(&:label).join(", ")
      tag_text = tags.present? ? " [#{tags}]" : ""
      "- #{e.occurred_on.strftime('%m/%d')}: #{e.body.truncate(80)}#{tag_text}"
    end.join("\n")
    "【ユーザーの直近のハレ記録】\n#{list}"
  end

  def output_guidelines
    <<~TEXT
      【分析の構成】
      以下の3点を中心に200〜300字でまとめてください：
      1. **食の傾向**: よく登場する食材・料理・パターン
      2. **バランスの観点**: 偏りや気になる点
      3. **おすすめ**: 次に試してみるとよいこと（具体的に1〜2つ）
    TEXT
  end
end
