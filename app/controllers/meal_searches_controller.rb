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

  def eat_out_redirect
    payload = session.delete("eat_out_redirect_#{params[:token]}")
    return redirect_to new_meal_search_path if payload.nil?

    @maps_url = payload["url"]
    @genre_label = payload["genre_label"]
    render :redirect_to_maps
  end

  def create
    result = MealSearchCreateService.call(user: current_user, params: params)
    if result.eat_out
      session["eat_out_redirect_#{result.token}"] = result.session_payload
      redirect_to eat_out_redirect_meal_searches_path(token: result.token)
    else
      session[:meal_candidates] = result.candidate_ids
      redirect_to meal_searches_path
    end
  end
end
