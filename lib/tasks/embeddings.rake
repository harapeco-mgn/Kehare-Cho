namespace :embeddings do
  desc "meal_candidates の embedding を生成・更新する"
  task backfill_meal_candidates: :environment do
    count = 0
    MealCandidate.where(embedding: nil).find_each do |candidate|
      source_text = [ candidate.name, candidate.genre&.label, candidate.mood_tag&.label, candidate.search_hint ].compact.join(" ")
      candidate.update_column(:embedding, EmbeddingService.generate(source_text))
      count += 1
      print "." if (count % 10).zero?
    end
    puts "\n#{count} 件の MealCandidate に embedding を生成しました"
  end

  desc "hare_entries の embedding を生成・更新する"
  task backfill_hare_entries: :environment do
    count = 0
    HareEntry.where(embedding: nil).find_each do |entry|
      entry.update_column(:embedding, EmbeddingService.generate(entry.body))
      count += 1
      print "." if (count % 10).zero?
    end
    puts "\n#{count} 件の HareEntry に embedding を生成しました"
  end

  desc "meal_searches の embedding を生成・更新する"
  task backfill_meal_searches: :environment do
    count = 0
    MealSearch.where(embedding: nil).find_each do |search|
      text = Array(search.presented_candidate_names).join(" ")
      search.update_column(:embedding, EmbeddingService.generate(text))
      count += 1
      print "." if (count % 10).zero?
    end
    puts "\n#{count} 件の MealSearch に embedding を生成しました"
  end

  desc "全テーブルの embedding を一括生成する"
  task backfill_all: %i[backfill_meal_candidates backfill_hare_entries backfill_meal_searches] do
    puts "全テーブルの embedding バックフィル完了"
  end
end
