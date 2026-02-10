module Seeds
  class PointRules
    def self.call
      PointRule.find_or_create_by!(key: 'post_base') do |rule|
        rule.label = 'ハレ投稿'
        rule.points = 1
        rule.priority = 1
        rule.is_active = true
        rule.description = '投稿作成で +1pt'
      end

      PointRule.find_or_create_by!(key: 'bonus_budget_up') do |rule|
        rule.label = '予算UP（500円以上）'
        rule.points = 1
        rule.params = { min_price_yen: 500 }
        rule.priority = 2
        rule.is_active = true
        rule.description = '予算500円以上で追加 +1pt'
      end

      PointRule.find_or_create_by!(key: 'daily_limit') do |rule|
        rule.label = '日次上限'
        rule.points = 3
        rule.priority = 99
        rule.is_active = false  # 設定値なので付与ルールではない
        rule.description = '1日あたりの獲得上限（設定値）'
      end
    end
  end
end
