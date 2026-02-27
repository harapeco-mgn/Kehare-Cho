class MealRagRetriever
  DEFAULT_LIMIT = 5

  def initialize(user:, query:, limit: DEFAULT_LIMIT)
    @user = user
    @query = query
    @limit = limit
    @query_embedding = EmbeddingService.generate(query)
  end

  # 3テーブルから類似度の高いレコードを取得して返す
  def retrieve
    {
      meal_candidates: search_meal_candidates,
      hare_entries: search_hare_entries,
      meal_searches: search_meal_searches
    }
  end

private

  def search_meal_candidates
    MealCandidate.active
                 .where.not(embedding: nil)
                 .nearest_neighbors(:embedding, @query_embedding, distance: "cosine")
                 .limit(@limit)
  end

  def search_hare_entries
    @user.hare_entries
         .where.not(embedding: nil)
         .nearest_neighbors(:embedding, @query_embedding, distance: "cosine")
         .limit(@limit)
  end

  def search_meal_searches
    @user.meal_searches
         .where.not(embedding: nil)
         .nearest_neighbors(:embedding, @query_embedding, distance: "cosine")
         .limit(@limit)
  end
end
