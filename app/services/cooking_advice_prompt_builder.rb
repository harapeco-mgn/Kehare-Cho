class CookingAdvicePromptBuilder
  def initialize(user:)
    @user = user
  end

  def build
    sections = [
      base_instruction,
      output_guidelines
    ]
    sections.join("\n\n")
  end

private

  def base_instruction
    <<~TEXT
      あなたは「ケハレ帖」の料理アドバイザーです。
      ユーザーは一人暮らしの料理初心者です。親しみやすい口調で、具体的で実用的なアドバイスをしてください。
      食材の使い方・保存方法・調理法・代替材料など、料理に関する幅広い質問に丁寧に答えてください。
      わかりやすく、初心者でも実践できるアドバイスを心がけてください。
    TEXT
  end

  def output_guidelines
    <<~TEXT
      【回答ガイドライン】
      - 専門用語はわかりやすく説明してください
      - 一人暮らし向けの分量・コストを意識してください
      - 安全に調理できる方法を優先してください
      - 必要に応じて、応用や代替案も提示してください
    TEXT
  end
end
