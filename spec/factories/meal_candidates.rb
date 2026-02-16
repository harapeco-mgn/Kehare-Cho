FactoryBot.define do
  factory :meal_candidate do
    association :genre
    sequence(:name) { |n| "料理名#{n}" }
    is_active { true }
    position { 1 }
    cook_context { :self_cook }
    minutes_max { 30 }
    mood_tag { nil }
  end
end
