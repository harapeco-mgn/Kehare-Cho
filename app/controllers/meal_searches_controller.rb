class MealSearchesController < ApplicationController
  before_action :authenticate_user!
  def new 
    @genres = Genre.all
    @moods = MoodTag.all
  end

  def create
  end

end
