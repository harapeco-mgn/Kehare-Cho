FactoryBot.define do
  factory :hare_tag do
    sequence(:key) { |n| "test_tag_#{n}" }
    sequence(:label) { |n| "テストタグ#{n}" }
    is_active { true }
    position { 1 }
  end
end
