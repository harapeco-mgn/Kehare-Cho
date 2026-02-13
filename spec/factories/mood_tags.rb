FactoryBot.define do
  factory :mood_tag do
    sequence(:key) { |n| "mood_#{n}" }
    sequence(:label) { |n| "気分タグ#{n}" }
    is_active { true }
    position { 1 }
  end
end
