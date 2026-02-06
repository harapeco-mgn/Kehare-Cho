class MealCandidate < ApplicationRecord
  belongs_to :genre

  validates :name, presence: true, uniqueness: { scope: :genre_id }

  scope :active, -> { where(is_active: true) }
  scope :sorted, -> { order(position: :asc) }
end
