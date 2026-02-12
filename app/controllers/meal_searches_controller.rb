class MealSearchesController < ApplicationController
  before_action :authenticate_user!
  def new
    @genres = Genre.all
    @moods = MoodTag.all
  end

  def create
    genre_id = params[:genre_id]
    picker = MealCandidatePicker.new(genre_id: genre_id)
    @candidates = picker.pick
    @genres = Genre.all
    @moods = MoodTag.all
    render :new
  end
end
