class Genre < ApplicationRecord
  has_many :meal_candidates, dependent: :destroy

  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9_]*\z/ }
  validates :label, presence: true, uniqueness: true

  # スコープ
  scope :active, -> { where(is_active: true) }
  scope :sorted, -> { order(position: :asc) }
end
