class MealCandidatePicker
  def initialize(genre_id:, random: Random.new)
    @genre_id = genre_id
    @random = random
  end

  def pick(count: 3)
    matched = fetch_matched_candidates

    if matched.size >= count
      matched.sample(count, random: @random)
    else
      supplement_candidates(matched, count)
    end
  end

  private

  def fetch_matched_candidates
    if @genre_id.present?
      MealCandidate.active.where(genre_id: @genre_id).includes(:genre).to_a
    else
      MealCandidate.active.includes(:genre).to_a
    end
  end

  def supplement_candidates(matched, count)
    remaining_count = count - matched.size
    excluded_ids = matched.map(&:id)

    other_candidates = MealCandidate.active.where.not(id: excluded_ids).includes(:genre).to_a

    supplemented = other_candidates.sample(remaining_count, random: @random)
    matched + supplemented
  end
end
