class PointAwardService
    DAILY_LIMIT = 3  # 日次上限

    # クラスメソッド（外部から呼ばれる入口）
    def self.call(hare_entry)
      new(hare_entry).call
    end

    # 初期化（インスタンス変数を設定）
    def initialize(hare_entry)
      @hare_entry = hare_entry
      @user = hare_entry.user
      @awarded_on = hare_entry.occurred_on
    end

    # 実際の処理
    def call
      # 1. 日次上限チェック
      # NOTE: 並行リクエスト対策として、将来的にはこの集計をトランザクション内で
      # ロック（行ロックまたはアドバイザリロック）してから読み取るべき。
      # 現状はMVPのため、シンプルな実装を優先。
      total_today = @user.point_transactions
                     .where(awarded_on: @awarded_on)
                     .sum(:points)
      remaining = DAILY_LIMIT - total_today

      return 0 if remaining <= 0

      # 2. トランザクション開始
      ActiveRecord::Base.transaction do
        # 3. 有効なルールを取得
        rules = PointRule.active.sorted

        # 4. ルールごとにポイントを付与
        rules.each do |rule|
          break if remaining <= 0

          points_to_award = [ rule.points, remaining ].min

          PointTransaction.create!(
            user: @user,
            hare_entry: @hare_entry,
            point_rule: rule,
            awarded_on: @awarded_on,
            points: points_to_award
          )

          remaining -= points_to_award
        end

        # 5. awarded_points キャッシュを更新
        total_awarded = @hare_entry.point_transactions.sum(:points)
        @hare_entry.update!(awarded_points: total_awarded)

        # 6. 付与したポイント数を返す
        total_awarded
      end
    end
end
