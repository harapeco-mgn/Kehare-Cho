FactoryBot.define do
  factory :hare_entry_tag do
    association :hare_entry
    association :hare_tag
  end
end
