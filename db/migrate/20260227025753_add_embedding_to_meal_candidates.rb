class AddEmbeddingToMealCandidates < ActiveRecord::Migration[8.1]
  def change
    add_column :meal_candidates, :embedding, :vector, limit: 768

    add_index :meal_candidates, :embedding,
      using: :hnsw,
      opclass: { embedding: :vector_cosine_ops }
  end
end
