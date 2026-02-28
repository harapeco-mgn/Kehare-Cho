class CalendarController < ApplicationController
  before_action :authenticate_user!  # ログイン認証

  def index
    # 表示開始日を取得（パラメータがなければ今月の1日）
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_month

    # 表示月のハレ投稿を取得（タグ込みで N+1 回避）
    @hare_entries = current_user.hare_entries.includes(:hare_tags).where(
      occurred_on: @start_date.beginning_of_month..@start_date.end_of_month
    )
    # 右パネルの初期表示用：今月最新エントリー
    @latest_entry = @hare_entries.max_by(&:occurred_on)
  end

  def show
    @date = params[:date].to_date
    @hare_entries = current_user.hare_entries.includes(:hare_tags).where(occurred_on: @date)
  rescue ArgumentError, TypeError
    # 不正な日付フォーマットの場合はカレンダートップへリダイレクト
    redirect_to calendar_path, alert: "日付の形式が正しくありません"
  end
end
