class HareEntryStatsService
  ENOUGH_DATA_THRESHOLD = 10
  PERIOD_DAYS = 30

  def initialize(user)
    @user = user
    @entries = user.hare_entries.where(occurred_on: PERIOD_DAYS.days.ago..)
  end

  def entry_count
    @entry_count ||= @entries.count
  end

  def recording_rate
    (entry_count * 100.0 / PERIOD_DAYS).round
  end

  def current_streak
    dates = @user.hare_entries
                 .order(occurred_on: :desc)
                 .pluck(:occurred_on)
                 .map(&:to_date)
                 .uniq
    streak = 0
    check_date = Date.today
    while dates.include?(check_date)
      streak += 1
      check_date -= 1.day
    end
    streak
  end

  def tag_ranking
    @tag_ranking ||= @entries
      .joins(:hare_tags)
      .group("hare_tags.label")
      .order(Arel.sql("COUNT(*) DESC"))
      .limit(3)
      .count
  end

  def total_points
    @total_points ||= @entries.sum(:awarded_points)
  end

  def average_points
    return 0 if entry_count.zero?

    (total_points.to_f / entry_count).round
  end

  def unique_days_count
    @unique_days_count ||= @entries.select(:occurred_on).distinct.count
  end

  def enough_data?
    unique_days_count >= ENOUGH_DATA_THRESHOLD
  end
end
