class PointRecalculationService
  # ハレ投稿に紐づくポイント履歴を削除→再付与する
  # PointAwardService も内部でトランザクションを持つが、Rails の仕様上
  # ネストされた transaction 呼び出しは同一 DB トランザクションを使うため問題なし
  def self.call(hare_entry)
    ActiveRecord::Base.transaction do
      hare_entry.point_transactions.destroy_all
      PointAwardService.call(hare_entry)
    end
  end

  # ハレ投稿削除後など、ユーザーの total_points 合計のみを再計算する
  def self.recalculate_total(user)
    user.update!(total_points: user.point_transactions.sum(:points))
  end
end
