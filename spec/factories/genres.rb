FactoryBot.define do
  factory :genre do
    sequence(:key) { |n| "genre_#{n}" }
    sequence(:label) { |n| "ジャンル#{n}" }
    is_active { true }
    position { 1 }
  end
end
