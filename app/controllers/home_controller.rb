class HomeController < ApplicationController
  def index
    @monthly_points = current_user.monthly_points if user_signed_in?
  end
end
