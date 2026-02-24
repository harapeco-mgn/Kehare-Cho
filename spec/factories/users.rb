FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:nickname) { |n| "テストユーザー#{n}" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
