FactoryBot.define do
  factory :point_transaction do
    association :user
    association :hare_entry
    association :point_rule
    awarded_on { Date.current }
    points { 10 }
  end
end
