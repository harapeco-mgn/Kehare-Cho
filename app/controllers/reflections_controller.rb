class ReflectionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @stats = HareEntryStatsService.new(current_user)
  end

  def analyze
    entries = HareEntryRetriever.new(user: current_user).retrieve
    system_prompt = ReflectionPromptBuilder.new(user: current_user, hare_entries: entries).build
    llm_chat = RubyLLM.chat
    llm_chat.with_instructions(system_prompt)
    response = llm_chat.ask("私の食生活の傾向を分析してください。")
    @analysis = response.content
  end
end
