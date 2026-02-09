FactoryBot.define do
  factory :hare_entry do
    association :user
    body { 'テスト投稿' }
    occurred_on { Date.today }
    visibility { :private_post }
  end
end
