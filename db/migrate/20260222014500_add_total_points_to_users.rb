class AddTotalPointsToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :total_points, :integer, default: 0, null: false

    # 既存ユーザーの total_points をバックフィル
    User.find_each do |user|
      user.update_column(:total_points, user.point_transactions.sum(:points))
    end
  end

  def down
    remove_column :users, :total_points
  end
end
