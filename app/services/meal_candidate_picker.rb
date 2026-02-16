class MealCandidatePicker
  FALLBACK_STEPS = [
    [],                                                  # Step 0: 全条件
    [ :mood_tag_id ],                                      # Step 1: mood 緩和
    [ :mood_tag_id, :required_minutes ],                   # Step 2: mood + minutes 緩和
    [ :mood_tag_id, :required_minutes, :cook_context ]     # Step 3: 全フィルタ緩和
  ].freeze

  def initialize(genre_id:, cook_context: nil, required_minutes: nil, mood_tag_id: nil, random: Random.new)
    @genre_id = genre_id
    @cook_context = cook_context
    @required_minutes = required_minutes&.to_i
    @mood_tag_id = mood_tag_id
    @random = random
  end

  def pick(count: 3)
    matched = []

    FALLBACK_STEPS.each do |relaxed|
      matched = fetch_with_relaxed(*relaxed)
      break if matched.size >= count
    end

    if matched.size >= count
      matched.sample(count, random: @random)
    else
      supplement_candidates(matched, count)
    end
  end

  private

  def fetch_with_relaxed(*relaxed_fields)
    scope = MealCandidate.active.includes(:genre, :mood_tag)

    scope = scope.where(genre_id: @genre_id) if @genre_id.present?

    unless relaxed_fields.include?(:cook_context)
      scope = scope.for_cook_context(@cook_context) if @cook_context.present?
    end

    unless relaxed_fields.include?(:required_minutes)
      scope = scope.within_minutes(@required_minutes) if @required_minutes.present?
    end

    unless relaxed_fields.include?(:mood_tag_id)
      scope = scope.for_mood(@mood_tag_id) if @mood_tag_id.present?
    end

    scope.to_a
  end

  def supplement_candidates(matched, count)
    remaining_count = count - matched.size
    excluded_ids = matched.map(&:id)

    other_candidates = MealCandidate.active.where.not(id: excluded_ids).includes(:genre, :mood_tag).to_a

    supplemented = other_candidates.sample(remaining_count, random: @random)
    matched + supplemented
  end
end
