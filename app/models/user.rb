class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  has_many :hare_entries, dependent: :destroy
  has_many :point_transactions, dependent: :destroy
  has_many :meal_searches, dependent: :destroy
  has_many :chats, dependent: :destroy

  validates :nickname, uniqueness: { case_sensitive: false }, length: { maximum: 20 }, allow_nil: true

  def monthly_points
    point_transactions.where(awarded_on: current_month_range).sum(:points)
  end

  def monthly_hare_entries_count
    hare_entries.where(occurred_on: current_month_range).count
  end

  def level
    return 0 if total_points <= 0
    (total_points - 1) / 10 + 1
  end

  def display_name
    nickname.presence || email.split("@").first
  end

  # OAuth ユーザーはパスワードを持たないため、validatable のパスワード必須チェックを回避
  def password_required?
    super && provider.blank?
  end

  # Google OAuth 認証後に呼ばれるファクトリメソッド
  # 検索優先度: ① provider+uid → ② 同メールの既存ユーザー → ③ 新規作成
  def self.from_omniauth(auth)
    # ① provider + uid で検索（2回目以降の OAuth ログイン）
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    # ② 同じメールアドレスの既存ユーザーがいれば紐付け
    user = find_by(email: auth.info.email)
    if user
      user.update!(provider: auth.provider, uid: auth.uid)
      return user
    end

    # ③ 完全な新規ユーザーを作成（パスワードはランダム生成）
    create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20]
    )
  end

private
  def current_month_range
    @current_month_range ||= Time.zone.now.beginning_of_month.to_date..Time.zone.now.end_of_month.to_date
  end
end
