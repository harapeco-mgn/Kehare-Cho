class MealSearchesController < ApplicationController
  before_action :authenticate_user!

  def index
    @meal_searches = current_user.meal_searches.order(created_at: :desc)
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
    if params[:cook_context] == "eat_out"
      # 外食の処理
      current_user.meal_searches.create!(
        cook_context: params[:cook_context],
        genre_id: params[:genre_id],
        presented_candidate_names: []
      )

      url = GoogleMapsQueryBuilder.new(params[:genre_id], params[:mood_tag_id]).url
      redirect_to url, allow_other_host: true
    else
      # 自炊の処理
      genre_id = params[:genre_id]
      picker = MealCandidatePicker.new(
        genre_id: genre_id,
        cook_context: :self_cook,
        required_minutes: params[:required_minutes],
        mood_tag_id: params[:mood_tag_id]
      )
      candidates = picker.pick
      current_user.meal_searches.create!(
        cook_context: :self_cook,
        genre_id: genre_id,
        required_minutes: params[:required_minutes],
        mood_id: params[:mood_tag_id],
        presented_candidate_names: candidates.map(&:name)
      )
      session[:meal_candidates] = candidates.map(&:id)
      redirect_to meal_searches_path
    end
  end

  private

  def meal_search_params
    params.permit(:genre_id, :cook_context, :mood_tag_id, :required_minutes)
  end
end
