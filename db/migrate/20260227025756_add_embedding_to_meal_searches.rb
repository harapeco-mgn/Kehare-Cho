class AddEmbeddingToMealSearches < ActiveRecord::Migration[8.1]
  def change
    add_column :meal_searches, :embedding, :vector, limit: 768

    add_index :meal_searches, :embedding,
      using: :hnsw,
      opclass: { embedding: :vector_cosine_ops }
  end
end
