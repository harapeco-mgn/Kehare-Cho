class MealSearch < ApplicationRecord
  belongs_to :user
  belongs_to :genre, optional: true

  serialize :presented_candidate_names, coder: JSON
  validates :user, presence: true

  enum :meal_mode, { ke: 0, hare: 1 }
  enum :cook_context, { self_cook: 0, eat_out: 1, ready_made: 2 }
end
