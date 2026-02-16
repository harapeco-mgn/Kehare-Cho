class MealCandidate < ApplicationRecord
  belongs_to :genre
  belongs_to :mood_tag, optional: true

  enum :cook_context, { self_cook: 0, eat_out: 1 }

  validates :name, presence: true, uniqueness: { scope: :genre_id }

  scope :active, -> { where(is_active: true) }
  scope :sorted, -> { order(position: :asc) }

  scope :for_cook_context, ->(ctx) { ctx.present? ? where(cook_context: ctx) : all }
  scope :within_minutes, ->(minutes) {
    return all if minutes.blank?

    where(minutes_max: ..minutes).or(where(minutes_max: nil))
  }
  scope :for_mood, ->(mood_tag_id) {
    return all if mood_tag_id.blank?

    where(mood_tag_id: mood_tag_id).or(where(mood_tag_id: nil))
  }
end
