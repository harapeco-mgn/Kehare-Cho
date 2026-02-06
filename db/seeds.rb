# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require_relative 'seeds/hare_tags'
require_relative 'seeds/genres'
require_relative 'seeds/mood_tags'
require_relative 'seeds/meal_candidates'

puts 'Seeding HareTags...'
Seeds::HareTags.call
puts "  ✓ #{HareTag.count} HareTags created"

puts 'Seeding Genres...'
Seeds::Genres.call
puts "  ✓ #{Genre.count} Genres created"

puts 'Seeding MoodTags...'
Seeds::MoodTags.call
puts "  ✓ #{MoodTag.count} MoodTags created"

puts 'Seeding MealCandidates...'
Seeds::MealCandidates.call
puts "  ✓ #{MealCandidate.count} MealCandidates created"
