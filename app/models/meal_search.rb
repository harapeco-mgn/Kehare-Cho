class MealSearch < ApplicationRecord
  has_neighbors :embedding

  belongs_to :user
  belongs_to :genre, optional: true

  serialize :presented_candidate_names, coder: JSON

  enum :meal_mode, { ke: 0, hare: 1 }
  enum :cook_context, { self_cook: 0, eat_out: 1, ready_made: 2 }

  before_save :generate_embedding, if: :presented_candidate_names_changed?

private

  def generate_embedding
    text = Array(presented_candidate_names).join(" ")
    self.embedding = EmbeddingService.generate(text)
  end
end
