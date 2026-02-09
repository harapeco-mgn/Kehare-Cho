class HareTag < ApplicationRecord
  has_many :hare_entry_tags, dependent: :destroy
  has_many :hare_entries, through: :hare_entry_tags

  validates :key, presence: true, uniqueness: true, format: { with: /\A[a-z][a-z0-9_]*\z/ }
  validates :label, presence: true, uniqueness: true

    # スコープ
    scope :active, -> { where(is_active: true) }
    scope :sorted, -> { order(position: :asc) }
end
