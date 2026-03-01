class HareEntry < ApplicationRecord
  has_neighbors :embedding

  belongs_to :user
  has_many :hare_entry_tags, dependent: :destroy
  has_many :hare_tags, through: :hare_entry_tags
  has_many :point_transactions, dependent: :destroy
  has_one_attached :photo

  attr_accessor :remove_photo

  enum :visibility, { public_post: 0, private_post: 1 }

  scope :publicly_visible, -> { where(visibility: :public_post) }
  scope :recent, -> { order(occurred_on: :desc, created_at: :desc) }
  scope :this_month, -> { where(occurred_on: Time.current.beginning_of_month.to_date..Time.current.end_of_month.to_date) }

  validates :body, presence: true, length: { maximum: 200 }
  validates :occurred_on, presence: true
  validates :photo, content_type: %w[image/jpeg image/png image/webp],
                    size: { less_than: 5.megabytes }
  validates :share_token, uniqueness: true, allow_nil: true

  before_save :ensure_share_token, if: -> { public_post? && share_token.blank? }
  before_save :generate_embedding, if: :body_changed?

private

  def ensure_share_token
    self.share_token = loop do
      token = SecureRandom.urlsafe_base64(16)
      break token unless HareEntry.exists?(share_token: token)
    end
  end

  def generate_embedding
    self.embedding = EmbeddingService.generate(body)
  end
end
