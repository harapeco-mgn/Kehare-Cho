class MealConsultationPromptBuilder
  CONVERSATION_TYPE_ROLES = {
    "meal_consultation" => "献立相談アシスタント",
    "cooking_advice"    => "料理アドバイザー",
    "reflection"        => "食生活分析アシスタント"
  }.freeze

  def initialize(user:, conversation_type:, rag_context:)
    @user = user
    @conversation_type = conversation_type.to_s
    @rag_context = rag_context
  end

  def build
    sections = [
      base_instruction,
      meal_candidates_context,
      past_entries_context,
      recent_searches_context,
      output_guidelines
    ]
    sections.compact.join("\n\n")
  end

private

  def base_instruction
    role = CONVERSATION_TYPE_ROLES[@conversation_type] || CONVERSATION_TYPE_ROLES["meal_consultation"]
    <<~TEXT
      あなたは「ケハレ帖」の#{role}です。
      ユーザーは一人暮らしの料理初心者です。親しみやすい口調で、具体的で実用的なアドバイスをしてください。
      提案は3候補以内にまとめ、それぞれ料理名・特徴・所要時間の目安を添えてください。
    TEXT
  end

  def meal_candidates_context
    candidates = @rag_context[:meal_candidates]
    return nil if candidates.blank?

    list = candidates.map do |c|
      hint = c.search_hint.present? ? "（#{c.search_hint}）" : ""
      "- #{c.name}#{hint}"
    end.join("\n")
    "【参考にできる献立候補】\n#{list}"
  end

  def past_entries_context
    entries = @rag_context[:hare_entries]
    return nil if entries.blank?

    list = entries.map do |e|
      date = e.occurred_on.strftime("%m/%d")
      "- #{date}: #{e.body.truncate(60)}"
    end.join("\n")
    "【ユーザーの過去の食事記録（参考）】\n#{list}"
  end

  def recent_searches_context
    searches = @rag_context[:meal_searches]
    return nil if searches.blank?

    names = searches.flat_map { |s| Array(s.presented_candidate_names) }.uniq.first(10)
    return nil if names.blank?

    list = names.map { |n| "- #{n}" }.join("\n")
    "【最近提案した料理（なるべく重複を避けてください）】\n#{list}"
  end

  def output_guidelines
    <<~TEXT
      【回答ガイドライン】
      - 料理名は具体的に記載してください（例:「鶏もも肉の照り焼き」）
      - 必要であれば Google 検索のキーワードを提案してください
      - 一人暮らし向けの分量・コストを意識してください
    TEXT
  end
end
