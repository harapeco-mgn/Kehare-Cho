class PointTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :hare_entry
  belongs_to :point_rule

  validates :awarded_on, presence: true
  validates :points, presence: true
  validates :point_rule_id, uniqueness: { scope: :hare_entry_id }
end
