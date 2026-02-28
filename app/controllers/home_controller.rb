class HomeController < ApplicationController
  def index
    if user_signed_in?
      @monthly_points = current_user.monthly_points
      @level = current_user.level
      @monthly_hare_entries_count = current_user.monthly_hare_entries_count
      @recent_hare_entries = current_user.hare_entries.order(occurred_on: :desc).limit(3)
      @calendar_dates = current_user.hare_entries.where(occurred_on: Time.current.all_month).pluck(:occurred_on)
    end
  end
end
