class CalendarController < ApplicationController
  before_action :authenticate_user!  # ログイン認証

  def index
    # 表示開始日を取得（パラメータがなければ今月の1日）
    @start_date = params[:start_date]&.to_date || Date.today.beginning_of_month

    # 表示月のハレ投稿のみ取得
    @hare_entries = current_user.hare_entries.where(
      occurred_on: @start_date.beginning_of_month..@start_date.end_of_month
    )
  end

  def show
    @date = params[:date].to_date
    @hare_entries = current_user.hare_entries.where(occurred_on: @date)
  rescue ArgumentError, TypeError
    # 不正な日付フォーマットの場合はカレンダートップへリダイレクト
    redirect_to calendar_path, alert: '不正な日付フォーマットです'
  end
end
