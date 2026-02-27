class ChangeEmbeddingDimensionTo3072 < ActiveRecord::Migration[8.1]
  # 前回の migration が途中で失敗し、meal_candidates が vector(3072)・インデックスなしの状態になった
  # → 768 次元 + HNSW インデックスに復元する（hare_entries / meal_searches と整合させる）
  def up
    remove_column :meal_candidates, :embedding
    add_column :meal_candidates, :embedding, :vector, limit: 768
    add_index :meal_candidates, :embedding,
      using: :hnsw,
      opclass: { embedding: :vector_cosine_ops }
  end

  def down
    remove_index :meal_candidates, :embedding
    remove_column :meal_candidates, :embedding
    add_column :meal_candidates, :embedding, :vector, limit: 768
    add_index :meal_candidates, :embedding,
      using: :hnsw,
      opclass: { embedding: :vector_cosine_ops }
  end
end
