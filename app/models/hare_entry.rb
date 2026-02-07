class HareEntry < ApplicationRecord
  belongs_to :user


  enum :visibility, { public_post: 0, private_post: 1 }

  validates :body, presence: true, length: { maximum: 280 }
  validates :occurred_on, presence: true
end
