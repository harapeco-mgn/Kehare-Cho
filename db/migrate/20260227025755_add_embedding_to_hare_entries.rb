class AddEmbeddingToHareEntries < ActiveRecord::Migration[8.1]
  def change
    add_column :hare_entries, :embedding, :vector, limit: 768

    add_index :hare_entries, :embedding,
      using: :hnsw,
      opclass: { embedding: :vector_cosine_ops }
  end
end
