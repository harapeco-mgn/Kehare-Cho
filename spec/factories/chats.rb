FactoryBot.define do
  factory :chat do
    association :user
    conversation_type { :meal_consultation }
  end
end
