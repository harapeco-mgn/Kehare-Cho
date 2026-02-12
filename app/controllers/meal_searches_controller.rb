class MealSearchesController < ApplicationController
  before_action :authenticate_user!

  def index
    if session[:meal_candidates]
      @candidates = MealCandidate.where(id: session[:meal_candidates]).includes(:genre)
    end
    @genres = Genre.all
    @moods = MoodTag.all
  end

  def new
    @genres = Genre.all
    @moods = MoodTag.all
  end

  def create
    genre_id = params[:genre_id]
    picker = MealCandidatePicker.new(genre_id: genre_id)
    candidates = picker.pick
    current_user.meal_searches.create!(genre_id: genre_id, presented_candidate_names: candidates.map(&:name))
    session[:meal_candidates] = candidates.map(&:id)
    redirect_to meal_searches_path
  end
end
