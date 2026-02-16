class HareEntry < ApplicationRecord
  belongs_to :user
  has_many :hare_entry_tags, dependent: :destroy
  has_many :hare_tags, through: :hare_entry_tags
  has_many :point_transactions, dependent: :destroy
  has_one_attached :photo

  attr_accessor :remove_photo

  enum :visibility, { public_post: 0, private_post: 1 }

  scope :publicly_visible, -> { where(visibility: :public_post) }
  scope :recent, -> { order(occurred_on: :desc, created_at: :desc) }

  validates :body, presence: true, length: { maximum: 280 }
  validates :occurred_on, presence: true
  validates :photo, content_type: %w[image/jpeg image/png image/webp],
                    size: { less_than: 5.megabytes }
end
