class MealSearchCreateService
  # サービス実行結果を保持するイミュータブルな値オブジェクト
  Result = Data.define(:eat_out, :token, :session_payload, :candidate_ids)

  def self.call(user:, params:)
    new(user: user, params: params).call
  end

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    if eat_out?
      perform_eat_out
    else
      perform_self_cook
    end
  end

  private

  def eat_out?
    @params[:cook_context] == "eat_out"
  end

  def perform_eat_out
    genre = Genre.find(@params[:genre_id])
    @user.meal_searches.create!(
      cook_context: @params[:cook_context],
      genre_id: @params[:genre_id],
      presented_candidate_names: []
    )
    token = SecureRandom.urlsafe_base64(8)
    Result.new(
      eat_out: true,
      token: token,
      session_payload: {
        "url" => GoogleMapsQueryBuilder.new(@params[:genre_id], @params[:mood_tag_id]).url,
        "genre_label" => genre.label
      },
      candidate_ids: nil
    )
  end

  def perform_self_cook
    picker = MealCandidatePicker.new(
      genre_id: @params[:genre_id],
      cook_context: :self_cook,
      required_minutes: @params[:required_minutes],
      mood_tag_id: @params[:mood_tag_id]
    )
    candidates = picker.pick
    @user.meal_searches.create!(
      cook_context: :self_cook,
      genre_id: @params[:genre_id],
      required_minutes: @params[:required_minutes],
      mood_id: @params[:mood_tag_id],
      presented_candidate_names: candidates.map(&:name)
    )
    Result.new(
      eat_out: false,
      token: nil,
      session_payload: nil,
      candidate_ids: candidates.map(&:id)
    )
  end
end
