FactoryBot.define do
  factory :point_rule do
    sequence(:key) { |n| "test_rule_#{n}" }
    sequence(:label) { |n| "テストルール#{n}" }
    points { 10 }
    priority { 1 }
    is_active { true }
  end
end
