FactoryBot.define do
  factory :meal_search do
    association :user
    meal_mode { 0 }
    cook_context { 0 }
    required_minutes { 20 }
    genre_id { 1 }
    mood_id { 1 }
    presented_candidate_names { [ '唐揚げ', 'カレー', '餃子' ] }
  end
end
