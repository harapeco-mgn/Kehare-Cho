class PointRule < ApplicationRecord
  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9_]*\z/ }
  validates :label, presence: true
  validates :points, presence: true
  validates :priority, presence: true

  # スコープ
  scope :active, -> { where(is_active: true) }
  scope :sorted, -> { order(priority: :asc) }
end
