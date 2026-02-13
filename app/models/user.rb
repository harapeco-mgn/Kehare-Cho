class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :hare_entries, dependent: :destroy
  has_many :point_transactions, dependent: :destroy
  has_many :meal_searches, dependent: :destroy

  validates :nickname, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :nickname, length: { maximum: 20 }, allow_nil: true

  def monthly_points
    point_transactions.where(awarded_on: current_month_range).sum(:points)
  end

  def monthly_hare_entries_count
    hare_entries.where(occurred_on: current_month_range).count
  end

  def level
    total_points = point_transactions.sum(:points)
    return 0 if total_points <= 0
    (total_points - 1) / 10 + 1
  end

  def display_name
    nickname.presence || email.split("@").first
  end

private
  def current_month_range
    @current_month_range ||= Time.zone.now.beginning_of_month.to_date..Time.zone.now.end_of_month.to_date
  end
end
