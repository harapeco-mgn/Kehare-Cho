class HareEntry < ApplicationRecord
  belongs_to :user
  has_many :hare_entry_tags, dependent: :destroy
  has_many :hare_tags, through: :hare_entry_tags

  enum :visibility, { public_post: 0, private_post: 1 }

  validates :body, presence: true, length: { maximum: 280 }
  validates :occurred_on, presence: true
end
