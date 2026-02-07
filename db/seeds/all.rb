module Seeds
  class All
    def self.call
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

      puts 'Seeding PointRules...'
      Seeds::PointRules.call
      puts "  ✓ #{PointRule.count} PointRules created"
    end
  end
end
