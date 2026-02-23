FactoryBot.define do
  factory :point_transaction do
    association :user
    association :hare_entry
    association :point_rule
    awarded_on { Date.current }
    points { 10 }

    # total_points カウンターキャッシュをテスト時も同期する
    after(:create) do |transaction|
      transaction.user.update_column(:total_points, transaction.user.point_transactions.sum(:points))
    end
  end
end
