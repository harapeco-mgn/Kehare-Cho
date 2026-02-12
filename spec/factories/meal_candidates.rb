FactoryBot.define do
  factory :meal_candidate do
    association :genre
    sequence(:name) { |n| "料理名#{n}" }
    is_active { true }
    position { 1 }
  end
end
