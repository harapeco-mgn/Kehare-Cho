class HareEntryTag < ApplicationRecord
  belongs_to :hare_entry
  belongs_to :hare_tag

  validates :hare_tag_id, uniqueness: { scope: :hare_entry_id }
  validate :hare_tag_must_be_active

  private

  def hare_tag_must_be_active
    return if hare_tag.nil?

    errors.add(:hare_tag, "は有効なタグである必要があります") unless hare_tag.is_active?
  end
end
