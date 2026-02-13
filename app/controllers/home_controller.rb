class HomeController < ApplicationController
  def index
    @monthly_points = current_user.monthly_points if user_signed_in?
    @level = current_user.level if user_signed_in?
    @monthly_hare_entries_count = current_user.monthly_hare_entries_count if user_signed_in?
  end
end
