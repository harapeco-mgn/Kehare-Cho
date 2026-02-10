class PointRecalculationService
  def self.call(hare_entry)
    ActiveRecord::Base.transaction do
      hare_entry.point_transactions.destroy_all
      PointAwardService.call(hare_entry)
    end
  end
end
