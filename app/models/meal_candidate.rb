class MealCandidate < ApplicationRecord
  has_neighbors :embedding

  belongs_to :genre
  belongs_to :mood_tag, optional: true

  enum :cook_context, { self_cook: 0, eat_out: 1 }

  before_save :generate_embedding, if: :embedding_source_changed?

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

private

  def generate_embedding
    source_text = [ name, genre&.label, mood_tag&.label, search_hint ].compact.join(" ")
    self.embedding = EmbeddingService.generate(source_text)
  end

  def embedding_source_changed?
    name_changed? || genre_id_changed? || mood_tag_id_changed? || search_hint_changed?
  end
end
