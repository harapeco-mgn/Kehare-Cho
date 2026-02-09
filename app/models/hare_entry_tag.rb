class HareEntryTag < ApplicationRecord
  belongs_to :hare_entry
  belongs_to :hare_tag

  validates :hare_tag_id, uniqueness: { scope: :hare_entry_id }
end
