class HareEntryRetriever
  RETRIEVAL_DAYS = 30
  LIMIT = 20

  def initialize(user:)
    @user = user
  end

  # 直近30日のハレ記録をタグ込みで取得する（時系列順）
  def retrieve
    @user.hare_entries
         .includes(:hare_tags)
         .where(occurred_on: RETRIEVAL_DAYS.days.ago..)
         .order(occurred_on: :desc)
         .limit(LIMIT)
  end
end
